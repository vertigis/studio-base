$user = $args[0]
$root = $args[1]
$_ = rmdir .temp -Force -Recurse -ErrorAction SilentlyContinue
$_ = mkdir .temp -ErrorAction SilentlyContinue
$_ = tar -czf .temp\context.tar.gz --exclude=.git --exclude=.temp --format=ustar .
$dir = ssh $user "mkdir -p `"$root`" && cd `"$root`" && echo `$PWD"
scp -qr .temp "$user`:$root"
ssh $user "cd `"$root`" && tar -xzf .temp/context.tar.gz && rm -rf .temp"

if (Get-Command code -ErrorAction SilentlyContinue) {
    code --install-extension ms-vscode-remote.remote-ssh --force
    code --folder-uri "vscode-remote://ssh-remote+$user$dir"
}
else {
    ssh -tt $user "cd `"$root`" && bash"
}
