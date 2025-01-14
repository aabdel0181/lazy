import re
from collections import defaultdict

def parse_containers(file_content):
    containers = re.findall(r'([^\s]+/[^\s]+:[^\s]+)', file_content)
    return [c.split('@')[0] for c in containers if not c.startswith('sha256:')]

def analyze_containers(file1, file2):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        containers1 = parse_containers(f1.read())
        containers2 = parse_containers(f2.read())
        print(f"Number of containers in file 1 (microk8s): {len(containers1)}")
        print(f"Number of containers in file 2 (hyperdos): {len(containers2)}")

        set1, set2 = set(containers1), set(containers2)

    print("\\nContainers unique to file 1 (microk8s):")
    for container in sorted(set1 - set2):
        print(container)

    print("\\nContainers unique to file 2 (hyperdos):")
    for container in sorted(set2 - set1):
        print(container)

    print("\\nSame containers with different versions:")
    versions = defaultdict(lambda: {'file1': [], 'file2': []})
    for container in containers1 + containers2:
        try:
            name, version = container.rsplit(':', 1)
        except ValueError:
            # If there's no version specified, use the whole string as the name
            name = container
            version = "unspecified"

        if container in set1:
            versions[name]['file1'].append(version)
        if container in set2:
            versions[name]['file2'].append(version)

    for name, ver in versions.items():
        if ver['file1'] and ver['file2'] and ver['file1'] != ver['file2']:
            print(f"{name}:")
            print(f"  File 1: {', '.join(ver['file1'])}")
            print(f"  File 2: {', '.join(ver['file2'])}")


analyze_containers('one.txt', 'two.txt')