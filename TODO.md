# ~~TODO~~

# DEPRECATED AND MIGRATED TO GITHUB ISSUES
### @ version: 0.1.0-beta

<!-- these are things to be done in the project
to be struck/checked off as completed incl. commit ID
and archived under (completed) before next version
the remainder at a version is rolled over to the next
    unless the item is dismissed altogether -->

### code

### documentation
- [ ] formatting needs work


### functionality
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
<details>
<summary>@ v0.1.0-beta</summary>

- [x] add `set -e` for entire script escaped by `set +e` where needed
    - pointed out by [@iammosespaulr](//github.com/iammosespaulr)
    - fixed @ [6ac1dd3](//github.com/kevinnls/bak-old/tree/6ac1dd30e64bf90b091eaa3d0c1536fbc411b8dd)
        - did not need escaping. -e does not apply to `test` conditions

- [x] `-d` has incorrect info
    - default is src dir
- [x] `-h` and `-v` are not mentioned
- [x] lightweight copy needs explanation
    - fixed @ [48f5669](//github.com/kevinnls/bak-old/tree/48f5669511d1463347979f973cd72e2dd6ec988a)

- [x] heavily dependent on GNU coreutils - `realpath`
    - unsatisfied dependency to be handled
    - fixed @ [8883fbf](//github.com/kevinnls/bak-old/tree/8883fbf068fbd8cc1d21b87fe075f3845404ba03)

</details>