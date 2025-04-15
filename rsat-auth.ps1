$id = Get-Content -Path "$env:USERPROFILE\.ssh\id_ed25519.pub" -First 1
ssh $args[0] "mkdir -p ~/.ssh && echo `"$id`" >> ~/.ssh/authorized_keys"
