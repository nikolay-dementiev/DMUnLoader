## What and why

## How it was tested

- [ ] `xcodebuild test` of the package on an iOS simulator
- [ ] `Scripts/test-example.sh` on a simulator, if the change can affect what the HUD shows or how it takes touches
- [ ] `Scripts/lint.sh`, `Scripts/check-api.sh` and `Scripts/check-manifest.sh`
- [ ] Every new test fails without the change

## Public API and behaviour

- [ ] The public interface is unchanged, or `Fixtures/API/public-interface.txt` is updated in the same commit
- [ ] Every change that people using the package can notice is in `CHANGELOG.md`
