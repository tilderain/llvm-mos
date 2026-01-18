#!/usr/bin/env python3
import re
import os

def reconstruct_files(input_files, output_dir="MOS_sources"):
    """
    Reconstructs individual source files from concatenated text files.
    
    Args:
        input_files (list): List of input filenames (e.g., ['alltd.txt', 'all.txt'])
        output_dir (str): Directory to save extracted files.
    """
    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created output directory: {output_dir}")

    for input_filename in input_files:
        if not os.path.exists(input_filename):
            print(f"Warning: {input_filename} not found. Skipping.")
            continue
            
        print(f"Processing {input_filename}...")
        
        try:
            with open(input_filename, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading {input_filename}: {e}")
            continue

        # Regex to identify file start markers.
        # Matches: //===-- Filename ...
        # Group 1: Filename
        # Group 2: Remainder of the header line (used for identification)
        pattern = re.compile(r"//===--\s+([\w\.-]+)(.*)")
        
        matches = list(pattern.finditer(content))
        
        if not matches:
            print(f"  No file markers found in {input_filename}.")
            continue

        for i in range(len(matches)):
            match = matches[i]
            filename = match.group(1)
            description = match.group(2)
            
            # The file content starts at the beginning of the regex match (the header)
            start_index = match.start()
            
            # The file content ends at the beginning of the next match, or the end of the file
            if i + 1 < len(matches):
                end_index = matches[i+1].start()
            else:
                end_index = len(content)
                
            file_content = content[start_index:end_index]
            
            # Fix for MOSInstrFormats.td:
            # In the source dump, MOSInstrFormats.td incorrectly has the header 
            # "//===-- MOSInstrInfo.td - MOS Instruction Formats ...".
            # We detect this by the description and rename it to the correct filename
            # to prevent it from overwriting the actual MOSInstrInfo.td.
            if filename == "MOSInstrInfo.td" and "Instruction Formats" in description:
                print(f"  [Info] Renaming file with description 'Instruction Formats' to MOSInstrFormats.td")
                filename = "MOSInstrFormats.td"
            
            out_path = os.path.join(output_dir, filename)
            
            try:
                with open(out_path, 'w', encoding='utf-8') as out_f:
                    out_f.write(file_content)
                    # Add a trailing newline if missing (cleaner for source files)
                    if file_content and not file_content.endswith('\n'):
                        out_f.write('\n')
                print(f"  Extracted: {filename}")
            except IOError as e:
                print(f"  Error writing {filename}: {e}")

if __name__ == "__main__":
    # The files provided in the prompt
    source_files = ["alltd.txt", "all.txt"]
    reconstruct_files(source_files)
    print("\nReconstruction complete.")
