How to add a new tool to the devtools setup.

# Create the Playbook

Add a file at `ansible/playbooks/<tool>.yml` following this template:

```yaml
---
- name: Install <tool>
  hosts: localhost
  gather_facts: true
  tasks:
    - name: Install <tool> (macOS via Homebrew)
      community.general.homebrew:
        name: <tool>
        state: present
      when: ansible_facts['system'] == 'Darwin'

    - name: Install <tool> (Windows via Chocolatey)
      chocolatey.chocolatey.win_chocolatey:
        name: <tool>
        state: present
      when: ansible_facts['os_family'] == 'Windows'
```

Use `community.general.homebrew_cask` instead of `homebrew` for macOS GUI applications.

# Register in Site Playbooks

Add the import to each platform's site playbook that should include the tool:

```yaml
# ansible/site-macos-arm64.yml or ansible/site-windows-amd64.yml
- import_playbook: playbooks/<tool>.yml
```

Order matters — place the import after any tools it depends on.
