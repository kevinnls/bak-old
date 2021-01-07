# TODO
### @ version: 0.1.0-beta

<!-- these are things to be done in the project
to be struck/checked off as completed incl. commit ID
and archived under (completed) before next version
the remainder at a version is rolled over to the next
    unless the item is dismissed altogether -->

### code
- [ ] add `set -e` for entire script escaped by `set +e` where needed
    - pointed out by [@iammosespaulr](//github.com/iammosespaulr)

### documentation
- [ ] `-d` has incorrect info
    - default is src dir
- [ ] `-h` and `-v` are not mentioned
- [ ] formatting needs work
- [ ] lightweight copy needs explanation

### functionality
- [ ] heavily dependent on GNU coreutils - `realpath`
    - unsatisfied dependency to be handled
- [ ] clone would overwrite existing .bak/.old
    - plan to rename existing file with ctime in suffix
- [ ] installation/uninstallation/update capabilities pending

### miscellaneous
- [ ] to decide and add license for RC
    - include in script keeping with zero-conf, single-file idea?

### completed
<!-- template START \
<details>
<summary>@ vN.N.N-xxx</summary>
</details>
     template END -->
