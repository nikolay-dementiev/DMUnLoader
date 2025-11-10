import subprocess
import csv
from collections import defaultdict
import os

def get_recurrent_file_changes():
    # Run git log to get commit details and changed files
    result = subprocess.run(
        ["git", "log", "--pretty=format:%ad : %H", "--date=short", "--name-only"],
        stdout=subprocess.PIPE,
        text=True
    )
    
    lines = result.stdout.split("\n")
    file_pairs = defaultdict(lambda: {"count": 0, "details": []})  # Store count and commit details for each file pair
    current_commit_files = set()
    current_commit_info = None

    for line in lines:
        if line.startswith("commit") or line.startswith("Date:") or line.startswith("20"):  # Detect commit info
            # Start of a new commit
            if current_commit_info and len(current_commit_files) > 1:
                for file1 in current_commit_files:
                    for file2 in current_commit_files:
                        if file1 != file2:
                            pair = tuple(sorted((file1, file2)))
                            file_pairs[pair]["count"] += 1
                            file_pairs[pair]["details"].append(current_commit_info)
            current_commit_files.clear()
            if line.strip():  # If this is not an empty line
                current_commit_info = line.strip()  # Save commit info (date + hash)
        elif not line.strip():  # End of a commit (empty line)
            continue
        else:
            # Add file to the current commit's file list
            if line:  # Ignore empty lines
                current_commit_files.add(line)

    # Process the last commit
    if current_commit_info and len(current_commit_files) > 1:
        for file1 in current_commit_files:
            for file2 in current_commit_files:
                if file1 != file2:
                    pair = tuple(sorted((file1, file2)))
                    file_pairs[pair]["count"] += 1
                    file_pairs[pair]["details"].append(current_commit_info)

    return file_pairs

def save_to_csv(file_pairs, output_dir, output_file):
    # Create the output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, output_file)

    with open(output_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["File1", "File2", "Count"])  # Write CSV headers
        
        # Check if there are any file pairs to write
        if not file_pairs:
            writer.writerow(["No recurrent file changes found."])
            return

        sorted_pairs = sorted(file_pairs.items(), key=lambda x: x[1]["count"], reverse=True)
        
        for (file1, file2), data in sorted_pairs:
            # Write general statistics for the file pair
            writer.writerow([file1, file2, data["count"]])
            
            # Write detailed commit information with reverse numbering
            writer.writerow(["Details:", "", ""])
            details = data["details"]
            for i, detail in enumerate(reversed(details), start=1):  # Reverse order with numbering
                writer.writerow([f"{i}: {detail}", "", ""])
            writer.writerow(["", "", ""])  # Add an empty row for separation

if __name__ == "__main__":
    # Determine the path to the Artifacts directory relative to the script
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    artifacts_dir = os.path.join(project_root, "Artifacts")
    
    # Get recurrent file changes
    file_pairs = get_recurrent_file_changes()
    
    # Save results to a CSV file
    save_to_csv(file_pairs, artifacts_dir, "recurrent_file_changes_detiled.csv")