Xtallography Release Notes
============================================================================================

--------------------------------------------------------------------------------------------
0.4.1 (2025-02-23)
==================
**Enhancements:**
- Improve robustness of Makefile targets.
- Bump Julia and Python version requirements to improve package reliability.

**Enhancements:**
- Fix bugs in CI workflow.

**Developer Updates:**
- Add developer notes.

--------------------------------------------------------------------------------------------
0.4.0 (2025-02-22)
==================
**Enhancements:**
- Renamed package to `Xtallography`.
- Added Python interface.
- Refactored lattice and unit cell code.
- Updated package documentation.

**Developer Updates:**
- Updated `Project.toml` files.
- Improved CI workflows.
- Added `Aqua` checks to unit tests.
- Updated GitHub Actions workflows.
- Updated pre-commit version and configuration.

--------------------------------------------------------------------------------------------
0.3.2 (2024-05-30)
==================
* Fix bugs in angle constraints for `TriclinicLatticeConstants`,
  `MonoclinicLatticeConstants`, `RhombohedralLatticeConstants` types.
* Update package infrastructure files (`Project.toml`, `CI.yaml`, `.ignore`).

--------------------------------------------------------------------------------------------
0.3.1 (2024-03-01)
==================
* Fix bugs in angle constraints for `TriclinicLatticeConstants`,
  `MonoclinicLatticeConstants`, `RhombohedralLatticeConstants` types.

--------------------------------------------------------------------------------------------
0.3.0 (2024-02-27)
==================
* Add `LatticeSystem` parameter to `LatticeConstants` and `LatticeConstantDeltas` types.
* Simplify implementation of `lattice_system()` methods.
* Fix minimum angle for rhombohedral unit cells.
* Update package documentation.
* Remove unnecessary imports.

--------------------------------------------------------------------------------------------
0.2.0 (2024-01-19)
==================
* Add `convert(::LatticeConstants)` and `convert(::LatticeConstantDeltas)` methods.
* Change `tol` argument to `is_equivalent_unit_cell()` to `atol` and `rtol` to be more
  consistent with other approximate comparison methods.
* Remove `norm()` methods.
* Update and improve unit tests.
* Update package documentation.
* Add cache for `build-docs` job in CI workflow.

--------------------------------------------------------------------------------------------
0.1.2 (2024-01-18)
==================
* Add `norm(::LatticeConstant)` method.

--------------------------------------------------------------------------------------------
0.1.1 (2024-01-07)
==================
* Add `LatticeConstantDeltas` types and functions.
* Add difference operator for `LatticeConstants` types.

--------------------------------------------------------------------------------------------
0.1.0 (2023-12-26)
==================
* Initial version of package.

--------------------------------------------------------------------------------------------
