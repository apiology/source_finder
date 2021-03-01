# SourceFinder

WARNING: This is not ready for use yet!

SourceFinder's job is to find source files in your project in a configurable way--useful for things like static analysis quality tools.

To publish new version as a maintainer:

```sh
git log "v$(bump current)..."
# Set type_of_bump to patch, minor, or major
bump --tag --tag-prefix=v ${type_of_bump:?}
rake release
```
