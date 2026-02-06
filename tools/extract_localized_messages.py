#!/usr/bin/env python3
"""
DOS Localized Message Extractor
===============================
Extracts localized messages from DOS executables using the known
structure from .CL* files.

Binary format (from assembled .CL* files):
  Class Header (4 bytes):
    [0] Class ID (01h=EXTEND, 02h=PARSE, 0Ah=CLASS_A, FFh=UTILITY)
    [1-2] Expected Version (00 04 = DOS 4.00, little-endian)
    [3] Message Count

  Message ID Table (4 bytes per message):
    [0-1] Message ID (little-endian)
    [2-3] Offset to message text (self-relative from entry, little-endian)

  Message Data (variable):
    [0] Length byte
    [1..N] Message text

Usage:
    extract_localized_messages.py english_format.clb localized_format.com
"""

import sys
import struct
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass
import parse_cl_files  # Import our CL parser

@dataclass
class BinaryMessageClass:
    """A message class found in a binary"""
    offset: int
    class_id: int
    version: int
    count: int
    messages: Dict[int, str]

    def __repr__(self):
        return f"<BinaryMessageClass at 0x{self.offset:04X}: ID=0x{self.class_id:02X}, {len(self.messages)} messages>"


class LocalizedMessageExtractor:
    """Extract localized messages from DOS executables"""

    def __init__(self, cl_path: Path, binary_path: Path):
        self.cl_path = cl_path
        self.binary_path = binary_path

        # Parse the English .CL* file to get structure
        parser = parse_cl_files.CLFileParser(cl_path)
        self.english_class = parser.parse()

        # Load binary
        self.binary_data = binary_path.read_bytes()

        # Results
        self.binary_classes: List[BinaryMessageClass] = []

    def find_message_classes(self) -> List[BinaryMessageClass]:
        """Scan binary for message class structures"""
        print(f"# Scanning {len(self.binary_data)} bytes for message classes...", file=sys.stderr)
        print(f"# Looking for class ID 0x{self.english_class.class_id:02X}", file=sys.stderr)

        classes = []

        # Scan through binary
        for offset in range(len(self.binary_data) - 4):
            # Read potential class header
            class_id = self.binary_data[offset]
            version_bytes = self.binary_data[offset+1:offset+3]
            count = self.binary_data[offset+3]

            # Check if this matches our expected class
            if class_id != self.english_class.class_id:
                continue

            # Version should be 00 04 (DOS 4.00) or similar
            version = struct.unpack('<H', version_bytes)[0]

            # Count should be reasonable and match what we expect
            expected_count = len(self.english_class.messages)
            if count != expected_count:
                continue

            # Verify this looks like a real message class by checking the structure
            if self._verify_message_class(offset, class_id, count):
                msg_class = self._extract_message_class(offset, class_id, version, count)
                if msg_class and len(msg_class.messages) > 0:
                    classes.append(msg_class)
                    print(f"# Found valid message class at 0x{offset:04X}", file=sys.stderr)

        return classes

    def _verify_message_class(self, offset: int, class_id: int, count: int) -> bool:
        """Verify this offset contains a valid message class structure"""
        # Check if there's enough space for the ID table
        id_table_size = count * 4
        if offset + 4 + id_table_size > len(self.binary_data):
            return False

        # Read the message ID table
        id_table_offset = offset + 4

        # Check that message IDs match what we expect
        expected_ids = sorted(self.english_class.messages.keys())
        found_ids = []

        for i in range(count):
            entry_offset = id_table_offset + (i * 4)
            msg_id = struct.unpack('<H', self.binary_data[entry_offset:entry_offset+2])[0]
            found_ids.append(msg_id)

        # Message IDs should match (order might differ)
        if sorted(found_ids) != sorted(expected_ids):
            return False

        # Check that message offsets point to readable data
        for i in range(min(3, count)):  # Check first 3 messages
            entry_offset = id_table_offset + (i * 4)
            msg_offset = struct.unpack('<H', self.binary_data[entry_offset+2:entry_offset+4])[0]
            # Offset is self-relative from the ID table entry
            text_offset = entry_offset + msg_offset

            if text_offset >= len(self.binary_data):
                return False

            # Read length byte
            length = self.binary_data[text_offset]

            # Length should be reasonable (1-255)
            if length == 0 or length > 200:
                return False

            # Check if text is mostly printable ASCII
            if text_offset + 1 + length > len(self.binary_data):
                return False

            text = self.binary_data[text_offset+1:text_offset+1+length]
            printable_count = sum(1 for b in text if (0x20 <= b <= 0x7E) or b in [0x0D, 0x0A])

            # At least 70% should be printable
            if printable_count < length * 0.7:
                return False

        return True

    def _extract_message_class(self, offset: int, class_id: int, version: int, count: int) -> Optional[BinaryMessageClass]:
        """Extract all messages from a message class"""
        messages = {}

        id_table_offset = offset + 4

        for i in range(count):
            entry_offset = id_table_offset + (i * 4)

            # Read message ID and offset
            msg_id = struct.unpack('<H', self.binary_data[entry_offset:entry_offset+2])[0]
            msg_offset = struct.unpack('<H', self.binary_data[entry_offset+2:entry_offset+4])[0]

            text_offset = entry_offset + msg_offset

            if text_offset < len(self.binary_data):
                length = self.binary_data[text_offset]

                if text_offset + 1 + length <= len(self.binary_data):
                    text_bytes = self.binary_data[text_offset+1:text_offset+1+length]

                    # Try CP850 first (multilingual), then CP437 (US)
                    try:
                        text = text_bytes.decode('cp850')
                    except (UnicodeDecodeError, LookupError):
                        try:
                            text = text_bytes.decode('cp437')
                        except (UnicodeDecodeError, LookupError):
                            text = text_bytes.decode('latin1', errors='replace')

                    messages[msg_id] = text

        return BinaryMessageClass(
            offset=offset,
            class_id=class_id,
            version=version,
            count=count,
            messages=messages
        )

    def extract_and_export(self, output=sys.stdout):
        """Find localized messages and export to .MSG format"""
        classes = self.find_message_classes()

        if not classes:
            print("# ERROR: No message classes found!", file=sys.stderr)
            print(f"# Expected class ID: 0x{self.english_class.class_id:02X}", file=sys.stderr)
            print(f"# Expected {len(self.english_class.messages)} messages", file=sys.stderr)
            return

        print(f"# Found {len(classes)} message class(es)", file=sys.stderr)

        # Use the first (or best) match
        msg_class = classes[0]

        print(f"# Extracted {len(msg_class.messages)} messages", file=sys.stderr)
        print(file=sys.stderr)

        # Export in .MSG format
        print("0085", file=output)

        class_name = f"CLASS_{self.english_class.class_name}"
        print(f"{class_name}   {len(msg_class.messages):04X} 0001", file=output)

        for msg_id in sorted(msg_class.messages.keys()):
            text = msg_class.messages[msg_id]

            # Format for .MSG file — CR/LF are comma-separated tokens outside quotes
            text_parts = []
            current = []
            for ch in text:
                if ch == '\r':
                    if current:
                        text_parts.append('"' + ''.join(current) + '"')
                        current = []
                    text_parts.append('CR')
                elif ch == '\n':
                    if current:
                        text_parts.append('"' + ''.join(current) + '"')
                        current = []
                    text_parts.append('LF')
                else:
                    current.append(ch)
            if current:
                text_parts.append('"' + ''.join(current) + '"')
            print(f'{msg_id:04X} U 0000 {",".join(text_parts)}', file=output)

        print(file=output)


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <ENGLISH.CLB> <LOCALIZED.COM>", file=sys.stderr)
        print(f"", file=sys.stderr)
        print(f"Example: {sys.argv[0]} format.clb format_dutch.com > dutch_format.msg", file=sys.stderr)
        print(f"", file=sys.stderr)
        print(f"This extracts localized messages by finding the binary structure", file=sys.stderr)
        print(f"defined in the English .CLB file within the localized executable.", file=sys.stderr)
        sys.exit(1)

    cl_path = Path(sys.argv[1])
    binary_path = Path(sys.argv[2])

    if not cl_path.exists():
        print(f"Error: {cl_path} not found", file=sys.stderr)
        sys.exit(1)

    if not binary_path.exists():
        print(f"Error: {binary_path} not found", file=sys.stderr)
        sys.exit(1)

    extractor = LocalizedMessageExtractor(cl_path, binary_path)
    extractor.extract_and_export()


if __name__ == "__main__":
    main()
