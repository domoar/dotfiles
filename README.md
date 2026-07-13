```bash
code --list-extensions | xargs -L 1 echo code --install-extension
```

```pwsh
code --list-extensions | ForEach-Object { "code --install-extension $_" }
```

```pwsh
code --profile "profile-name" --list-extensions
```