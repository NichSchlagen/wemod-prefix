# WeMod Prefix

Pre-built Wine prefix for [wemod-launcher](https://github.com/NichSchlagen/wemod-proton-launcher-go), pre-configured with `corefonts` and `dotnet48`.

## For Users

Instead of building locally (~20-30 min), just download the ready-made prefix (~2-3 min):

```bash
./wemod prefix download
```

Or grab the ZIP manually from the [Releases page](https://github.com/NichSchlagen/wemod-prefix/releases/latest).

The prefix works with Wine 9.0 and newer.

## For Maintainers (Publishing a New Prefix)

### Requirements

- `wine` and `winetricks`
- `zip`
- `gh` CLI ([install](https://cli.github.com), then `gh auth login`)

### Workflow

**Step 1 — Build the prefix locally:**
```bash
./scripts/build-prefix.sh
```
This takes ~20-30 minutes and produces `wemod_prefix.zip`.

**Step 2 — Publish to GitHub:**
```bash
./scripts/release.sh
```
This deletes the old `latest` release and uploads the new ZIP.

That's it. Users can then run `./wemod prefix download` to get the new prefix.

## File Structure

```
wemod-prefix/
├── scripts/
│   ├── build-prefix.sh   # Build the prefix locally
│   └── release.sh        # Publish via gh CLI
├── .gitignore
└── README.md
```

## Compatibility

| Wine | Status |
|---|---|
| 11.0 | Built with this version |
| 9.0–10.x | Compatible (backward compatible) |
| < 9.0 | Not supported |

## Troubleshooting

**Download fails:**
- Check the [Releases page](https://github.com/NichSchlagen/wemod-prefix/releases) for the `latest` tag
- Fall back to local build: `./wemod prefix build`

**Prefix doesn't work:**
- Ensure Wine 9.0+ is installed
- Reset and rebuild: `./wemod reset` then `./wemod prefix build`

**ZIP is much larger than the prefix (for example 1.2 GB prefix, multi-GB ZIP):**
- Cause: `dosdevices/c:` is a symlink to `../drive_c`. If symlinks are dereferenced while zipping, `drive_c` is archived again under `dosdevices/c:/...`.
- Fix: build using `./scripts/build-prefix.sh` from this repository version. The script archives symlinks as links and runs a sanity check to prevent this duplication.

## License

Same as [wemod-launcher](https://github.com/NichSchlagen/wemod-proton-launcher-go).
