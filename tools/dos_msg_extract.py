#!/usr/bin/env python3
"""
DOS Message Extractor
====================
Extracts localized messages from MS-DOS 4.x executables.

Usage:
    dos_msg_extract.py FORMAT.COM > format_messages.txt
"""

import sys
import struct
from pathlib import Path
from typing import List, Dict, Tuple, Optional

class DOSMessageClass:
    """Represents a message class in a DOS executable"""

    def __init__(self, class_id: int, version: int, offset: int):
        self.class_id = class_id
        self.version = version
        self.offset = offset
        self.messages: Dict[int, str] = {}

    def __repr__(self):
        class_names = {
            0x01: "EXTEND (Extended Errors)",
            0x02: "PARSE (Parse Errors)",
            0x0A: "CLASS_A (Resident Messages)",
            0xFF: "UTILITY (Utility Messages)"
        }
        name = class_names.get(self.class_id, f"CLASS_{self.class_id:02X}")
        return f"<MessageClass {name} at 0x{self.offset:04X}, {len(self.messages)} messages>"


class DOSMessageExtractor:
    """Extract messages from DOS executables"""

    # Known valid class IDs
    VALID_CLASS_IDS = {0x01, 0x02, 0x0A, 0x0B, 0x0C, 0xFF}

    def __init__(self, exe_path: Path):
        self.exe_path = exe_path
        self.data = exe_path.read_bytes()
        self.classes: List[DOSMessageClass] = []

    def is_valid_class_header(self, offset: int) -> bool:
        """Check if offset points to a valid message class header"""
        if offset + 4 > len(self.data):
            return False

        class_id = self.data[offset]
        version = struct.unpack_from('<H', self.data, offset + 1)[0]
        count = self.data[offset + 3]

        # Sanity checks
        if class_id not in self.VALID_CLASS_IDS:
            return False

        # DOS 4.x version check (0x0400 = 4.00)
        if version != 0x0400:
            return False

        # Message count should be reasonable (1-100)
        if count < 1 or count > 100:
            return False

        # Check if there's enough space for the message table
        table_size = count * 4  # Each entry is 4 bytes
        if offset + 4 + table_size > len(self.data):
            return False

        return True

    def find_message_classes(self) -> List[DOSMessageClass]:
        """Scan binary for message class headers"""
        classes = []

        # Scan the entire file, but skip the first 0x100 bytes (likely code)
        for offset in range(0x100, len(self.data) - 4):
            if self.is_valid_class_header(offset):
                class_id = self.data[offset]
                version = struct.unpack_from('<H', self.data, offset + 1)[0]

                msg_class = DOSMessageClass(class_id, version, offset)
                classes.append(msg_class)

        return classes

    def extract_messages_from_class(self, msg_class: DOSMessageClass) -> None:
        """Extract all messages from a message class"""
        offset = msg_class.offset
        count = self.data[offset + 3]

        # Read message ID table
        table_offset = offset + 4

        for i in range(count):
            entry_offset = table_offset + (i * 4)
            msg_id = struct.unpack_from('<H', self.data, entry_offset)[0]
            msg_offset = struct.unpack_from('<H', self.data, entry_offset + 2)[0]

            # Offset is self-relative from the ID table entry
            text_offset = entry_offset + msg_offset

            # Read message text (length-prefixed)
            if text_offset < len(self.data):
                msg_len = self.data[text_offset]

                if text_offset + 1 + msg_len <= len(self.data):
                    msg_bytes = self.data[text_offset + 1 : text_offset + 1 + msg_len]

                    # Try to decode (CP437 for US, CP850 for international)
                    try:
                        msg_text = msg_bytes.decode('cp437')
                    except (UnicodeDecodeError, LookupError):
                        msg_text = msg_bytes.decode('latin1', errors='replace')

                    msg_class.messages[msg_id] = msg_text

    def extract_all(self) -> List[DOSMessageClass]:
        """Find and extract all message classes"""
        self.classes = self.find_message_classes()

        for msg_class in self.classes:
            self.extract_messages_from_class(msg_class)

        return self.classes

    def format_message(self, text: str) -> str:
        """Format message text for display, showing control characters"""
        # Replace control characters with readable representations
        text = text.replace('\r', '<CR>')
        text = text.replace('\n', '<LF>')
        text = text.replace('\x00', '<NUL>')
        return text

    def print_report(self) -> None:
        """Print a formatted report of all messages"""
        print(f"DOS Message Extraction Report")
        print(f"=" * 70)
        print(f"File: {self.exe_path}")
        print(f"Size: {len(self.data)} bytes")
        print(f"Classes found: {len(self.classes)}")
        print()

        for msg_class in self.classes:
            print(f"{msg_class}")
            print(f"Version: {msg_class.version:04X} (DOS {msg_class.version >> 8}.{msg_class.version & 0xFF})")
            print(f"Offset: 0x{msg_class.offset:04X}")
            print()

            for msg_id, msg_text in sorted(msg_class.messages.items()):
                formatted_text = self.format_message(msg_text)
                print(f"  [{msg_id:04X}] {formatted_text}")

            print()

    def export_to_msg_format(self, output_path: Path, class_name: str = "COMMON") -> None:
        """Export messages to BUILDMSG-compatible .MSG format"""
        with output_path.open('w', encoding='latin1') as f:
            # Write header
            f.write("0085\n")

            for msg_class in self.classes:
                # Map class ID to name
                class_names = {
                    0x01: "EXTEND",
                    0x02: "PARSE",
                    0x0A: "CLASS_A",
                    0x0B: "CLASS_B",
                    0x0C: "CLASS_C",
                    0xFF: "UTILITY"
                }
                cls_name = class_names.get(msg_class.class_id, f"CLASS_{msg_class.class_id:02X}")

                # Write class header
                f.write(f"{cls_name}   {len(msg_class.messages):04X} 0001\n")

                # Write messages
                for msg_id, msg_text in sorted(msg_class.messages.items()):
                    # Convert back to MSG format — CR/LF as tokens outside quotes
                    text_parts = []
                    current = []
                    for ch in msg_text:
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
                    f.write(f"{msg_id:04X} U 0000 {','.join(text_parts)}\n")

                f.write("\n")


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <DOS_EXECUTABLE>", file=sys.stderr)
        print(f"", file=sys.stderr)
        print(f"Example: {sys.argv[0]} FORMAT.COM", file=sys.stderr)
        sys.exit(1)

    exe_path = Path(sys.argv[1])

    if not exe_path.exists():
        print(f"Error: {exe_path} not found", file=sys.stderr)
        sys.exit(1)

    extractor = DOSMessageExtractor(exe_path)
    extractor.extract_all()
    extractor.print_report()


if __name__ == "__main__":
    main()
