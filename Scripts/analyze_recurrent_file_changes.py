import subprocess
import csv
from collections import defaultdict
import os

def get_recurrent_file_changes():
    # Getting git log output
    result = subprocess.run(
        ["git", "log", "--pretty=format:", "--name-only"],  # Excluding commit hashes
        stdout=subprocess.PIPE,
        text=True
    )
    
    lines = result.stdout.split("\n")
    file_pairs = defaultdict(int)  # We store the number of shared changes for each pair of files
    current_commit_files = set()

    for line in lines:
        if not line.strip():  # Empty line - end of commit
            if len(current_commit_files) > 1:
                for file1 in current_commit_files:
                    for file2 in current_commit_files:
                        if file1 != file2:
                            pair = tuple(sorted((file1, file2)))
                            file_pairs[pair] += 1  # Increment the counter for a pair of files
            current_commit_files.clear()  # Clearing the file list for a new commit
        elif line.startswith("commit"):  # Ignore lines with commit hashes
            continue
        else:
            # Add the file to the current commit
            if line:  # Ignore empty lines
                current_commit_files.add(line)

    # Processing the last commit
    if len(current_commit_files) > 1:
        for file1 in current_commit_files:
            for file2 in current_commit_files:
                if file1 != file2:
                    pair = tuple(sorted((file1, file2)))
                    file_pairs[pair] += 1

    return file_pairs

def save_to_csv(file_pairs, output_dir, output_file):
    # Create a folder if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, output_file)

    with open(output_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["File1", "File2", "Count"])  # Headlines
        sorted_pairs = sorted(file_pairs.items(), key=lambda x: x[1], reverse=True)
        for (file1, file2), count in sorted_pairs:
            writer.writerow([file1, file2, count])

if __name__ == "__main__":
    # Determine the path to the Artifacts folder relative to the script
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    artifacts_dir = os.path.join(project_root, "Artifacts")
    
    file_pairs = get_recurrent_file_changes()
    save_to_csv(file_pairs, artifacts_dir, "recurrent_file_changes.csv")