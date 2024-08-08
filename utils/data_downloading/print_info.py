import os

def get_directory_stats(directory):
    """Calculate the number of files and total size of a directory."""
    total_size = 0
    file_count = 0
    for dirpath, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            if os.path.isfile(file_path):
                total_size += os.path.getsize(file_path)
                file_count += 1
    return file_count, total_size

def calculate_directory_statistics(base_directory):
    """Calculate and print statistics for each subdirectory in a table-like format."""
    subdirs = [d for d in os.listdir(base_directory) if os.path.isdir(os.path.join(base_directory, d))]
    
    # Print table header
    print(f"{'Subdirectory':<30} {'Size (GB)':<15} {'Number of Files':<15}")
    print("-" * 60)
    
    for subdir in subdirs:
        subdir_path = os.path.join(base_directory, subdir)
        file_count, total_size = get_directory_stats(subdir_path)
        
        # Convert total_size to GB
        size_in_gb = total_size / (1024 ** 3)
        
        # Print table row
        print(f"{subdir:<30} {size_in_gb:<15.4f} {file_count:<15}")

# Base directory path
base_directory = '/raid/xbfr/data'

# Calculate and print directory statistics
calculate_directory_statistics(base_directory)