#   Copyright 2023 Velexi Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

"""
Tests for methods in lattice/monoclinic.jl (except for cell standardization methods)
"""
# --- Imports

# Standard library
using Test
using LinearAlgebra: det, dot, norm, cross

# XtallographyUtils package
using XtallographyUtils

# --- Tests

# ------ Types

@testset "MonoclinicLatticeConstants constructor: valid arguments" begin
    # --- Preparations

    a = 1
    b = 2
    c = 3
    β = π / 4

    # --- Exercise functionality and check results

    # ------ basic test

    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    @test lattice_constants.a == a
    @test lattice_constants.b == b
    @test lattice_constants.c == c
    @test lattice_constants.β == β

    # ------ edge cases for β

    # β = 0
    lattice_constants = MonoclinicLatticeConstants(a, b, c, 0)

    @test lattice_constants.a == a
    @test lattice_constants.b == b
    @test lattice_constants.c == c
    @test lattice_constants.β == 0

    # β = π
    lattice_constants = MonoclinicLatticeConstants(a, b, c, π)

    @test lattice_constants.a == a
    @test lattice_constants.b == b
    @test lattice_constants.c == c
    @test lattice_constants.β ≈ π
end

@testset "MonoclinicLatticeConstants constructor: invalid arguments" begin
    # --- Preparations

    # Valid arguments
    a = 1
    b = 2
    c = 3
    β = π / 4

    # --- Tests

    # ------ a

    # a = 0
    local error = nothing
    local error_message = ""
    try
        lattice_constants = MonoclinicLatticeConstants(0, b, c, β)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `a` must be positive"
    @test startswith(error_message, expected_error)

    # a < 0
    local error = nothing
    local error_message = ""
    try
        lattice_constants = MonoclinicLatticeConstants(-1.0, b, c, β)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `a` must be positive"
    @test startswith(error_message, expected_error)

    # ------ b

    # b = 0
    local error = nothing
    local error_message = ""
    try
        lattice_constants = MonoclinicLatticeConstants(a, 0, c, β)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `b` must be positive"
    @test startswith(error_message, expected_error)

    # b < 0
    local error = nothing
    local error_message = ""
    try
        lattice_constants = MonoclinicLatticeConstants(a, -1.0, c, β)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `b` must be positive"
    @test startswith(error_message, expected_error)

    # ------ c

    # c = 0
    local error = nothing
    local error_message = ""
    try
        lattice_constants = MonoclinicLatticeConstants(a, b, 0, β)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `c` must be positive"
    @test startswith(error_message, expected_error)

    # c < 0
    local error = nothing
    local error_message = ""
    try
        lattice_constants = MonoclinicLatticeConstants(a, b, -1.0, β)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `c` must be positive"
    @test startswith(error_message, expected_error)

    # ------ β

    # β < 0
    local error = nothing
    local error_message = ""
    try
        lattice_constants = MonoclinicLatticeConstants(a, b, c, -1.0)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `β` must lie in the interval [0, π]"
    @test startswith(error_message, expected_error)

    # β > π
    local error = nothing
    local error_message = ""
    try
        lattice_constants = MonoclinicLatticeConstants(a, b, c, π + 1)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `β` must lie in the interval [0, π]"
    @test startswith(error_message, expected_error)
end

# ------ LatticeConstants functions

@testset "isapprox(::LatticeConstants)" begin
    # --- Preparations

    x = MonoclinicLatticeConstants(1.0, 2.0, 3.0, π / 5)
    y = MonoclinicLatticeConstants(1.5, 2.5, 3.5, π / 5 + 0.5)

    # --- Exercise functionality and check results

    # x ≈ (x + delta)
    @test x ≈ MonoclinicLatticeConstants(1.0 + 1e-9, 2.0, 3.0, π / 5)
    @test x ≈ MonoclinicLatticeConstants(1.0, 2.0 + 1e-9, 3.0, π / 5)
    @test x ≈ MonoclinicLatticeConstants(1.0, 2.0, 3.0 - 1e-9, π / 5)
    @test x ≈ MonoclinicLatticeConstants(1.0, 2.0, 3.0, π / 5 - 1e-9)

    # x !≈ y
    @test !(x ≈ y)

    # x ≈ y: atol = 1
    @test isapprox(x, y; atol=1)

    # x ≈ y: rtol = 1
    @test isapprox(x, y; rtol=1)

    # x ≈ y: atol = 0.01, rtol = 1
    @test isapprox(x, y; atol=0.01, rtol=1)

    # x ≈ y: atol = 1, rtol = 0.01
    @test isapprox(x, y; atol=1, rtol=0.01)

    # x !≈ y: atol = 0.01, rtol = 0.01
    @test !isapprox(x, y; atol=0.01, rtol=0.01)
end

@testset "lattice_system()" begin
    # --- Tests

    lattice_constants = MonoclinicLatticeConstants(1, 2, 3, π / 5)
    @test lattice_system(lattice_constants) == Monoclinic
end

@testset "standardize()" begin
    # --- Tests

    # ------ lattice constants already in standard form

    a = 6
    b = 10
    c = 8
    β = 1.1 * π / 2
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    # centering = PRIMITIVE
    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.PRIMITIVE
    )

    expected_lattice_constants = MonoclinicLatticeConstants(a, b, c, β)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.PRIMITIVE

    # centering = BODY
    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.BODY
    )

    expected_lattice_constants = MonoclinicLatticeConstants(a, b, c, β)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.BODY

    # ------ β ∉ [π/2, π]

    a = 6
    b = 10
    c = 8
    β = π - 1.1 * π / 2
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    # centering = PRIMITIVE
    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.PRIMITIVE
    )

    expected_lattice_constants = MonoclinicLatticeConstants(a, b, c, π - β)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.PRIMITIVE

    # centering = BODY
    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.BODY
    )

    expected_lattice_constants = MonoclinicLatticeConstants(a, b, c, π - β)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.BODY

    # ------ a > c

    a = 8
    b = 10
    c = 6
    β = 1.1 * π / 2
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    # centering = PRIMITIVE
    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.PRIMITIVE
    )

    expected_lattice_constants = MonoclinicLatticeConstants(c, b, a, β)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.PRIMITIVE

    # centering = BODY
    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.BODY
    )

    expected_lattice_constants = MonoclinicLatticeConstants(c, b, a, β)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.BODY

    # ------ base-centered unit cell, a < c

    a = 6
    b = 10
    c = 8
    β = 1.1 * π / 2
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.BASE
    )

    a_body = sqrt(a^2 + c^2 + 2 * a * c * cos(β))
    β_body = π - asin(sin(β) / a_body * a)
    expected_lattice_constants = MonoclinicLatticeConstants(c, b, a_body, β_body)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.BODY

    # ------ base-centered unit cell, a > c

    a = 8
    b = 10
    c = 6
    β = 1.1 * π / 2
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.BASE
    )

    a_body = sqrt(a^2 + c^2 + 2 * a * c * cos(β))
    β_body = π - asin(sin(β) / a_body * a)
    expected_lattice_constants = MonoclinicLatticeConstants(c, b, a_body, β_body)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.BODY

    # ------ unit cell requires single reduction in plane normal to b-axis

    a_ref = 6
    b_ref = 10
    c_ref = 8
    β_ref = 2π / 3

    # centering = PRIMITIVE
    a = a_ref
    b = b_ref
    c = c_ref
    β = β_ref
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.PRIMITIVE
    )

    expected_c = sqrt(a^2 + c^2 + 2 * a * c * cos(β))
    expected_β = π - asin(sin(β) / expected_c * c)
    expected_lattice_constants = MonoclinicLatticeConstants(a, b, expected_c, expected_β)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.PRIMITIVE

    # centering = BODY
    a = a_ref
    b = b_ref
    c = sqrt((2 * a_ref)^2 + c_ref^2 + 2 * (2 * a_ref) * c_ref * cos(β_ref))
    β = π - asin(sin(β_ref) / c * c_ref)
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.BODY
    )

    expected_lattice_constants = MonoclinicLatticeConstants(a_ref, b_ref, c_ref, β_ref)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.BODY

    # ------ unit cell requires multiple reductions in plane normal to b-axis

    a_ref = 6
    b_ref = 10
    c_ref = 8
    β_ref = 2π / 3

    # centering = PRIMITIVE
    a = a_ref
    b = b_ref
    c = sqrt((5 * a_ref)^2 + c_ref^2 + 2 * (5 * a_ref) * c_ref * cos(β_ref))
    β = asin(sin(β_ref) / c * c_ref)
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.PRIMITIVE
    )

    expected_c = sqrt(a_ref^2 + c_ref^2 + 2 * a_ref * c_ref * cos(β_ref))
    expected_β = π - asin(sin(β_ref) / expected_c * c_ref)
    expected_lattice_constants = MonoclinicLatticeConstants(a, b, expected_c, expected_β)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.PRIMITIVE

    # centering = BODY
    a = a_ref
    b = b_ref
    c = sqrt((5 * a_ref)^2 + c_ref^2 + 2 * (5 * a_ref) * c_ref * cos(β_ref))
    β = asin(sin(β_ref) / c * c_ref)
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    standardized_lattice_constants, standardized_centering = standardize(
        lattice_constants, XtallographyUtils.BODY
    )

    expected_lattice_constants = MonoclinicLatticeConstants(a, b, expected_c, expected_β)
    @test standardized_lattice_constants ≈ expected_lattice_constants

    @test standardized_centering == XtallographyUtils.BODY

    # ------ Invalid centering

    # centering = FACE
    centering = XtallographyUtils.FACE
    local error = nothing
    local error_message = ""
    try
        standardize(lattice_constants, centering)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error =
        "ArgumentError: " *
        "Invalid Bravais lattice: (lattice_system=Monoclinic, centering=$centering)"

    @test startswith(error_message, expected_error)
end

# ------ Unit cell computations

@testset "basis()" begin
    # --- Preparations

    a = 2
    b = 3
    c = 5
    β = 3π / 5
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    # --- Exercise functionality

    basis_a, basis_b, basis_c = basis(lattice_constants)

    # --- Check results

    @test basis_a ≈ [a, 0, 0]
    @test basis_b ≈ [0, b, 0]
    @test basis_c ≈ [c * cos(β), 0, c * sin(β)]
end

@testset "volume()" begin
    # --- Preparations

    # Construct basis vectors for unit cell
    a = 6
    b = 3
    c = 10
    β = 3π / 5
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    basis_a, basis_b, basis_c = basis(lattice_constants)

    # --- Exercise functionality and check results

    @test volume(lattice_constants) ≈ abs(det(hcat(basis_a, basis_b, basis_c)))
end

@testset "surface_area()" begin
    # --- Preparations

    # Construct basis vectors for unit cell
    a = 6
    b = 3
    c = 10
    β = 3π / 5
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    basis_a, basis_b, basis_c = basis(lattice_constants)

    # --- Exercise functionality and check results

    @test surface_area(lattice_constants) ≈
        2 * norm(cross(basis_a, basis_b)) +
          2 * norm(cross(basis_b, basis_c)) +
          2 * norm(cross(basis_c, basis_a))
end

@testset "convert_to_body_centering()" begin
    # --- Preparations

    # Construct basis vectors for body-centered unit cell
    a = 6
    b = 3
    c = 10
    β = 3π / 5
    base_centered_lattice_constants = MonoclinicLatticeConstants(a, b, c, β)

    # --- Exercise functionality and check results

    # Check conversion to body-centering
    body_centered_lattice_constants = convert_to_body_centering(
        base_centered_lattice_constants
    )

    a_body = sqrt(a^2 + c^2 + 2 * a * c * cos(β))
    c_body = c
    β_body = π - acos((a_body^2 + c_body^2 - a^2) / 2 / a_body / c_body)
    expected_body_centered_lattice_constants = MonoclinicLatticeConstants(
        a_body, b, c_body, β_body
    )
    @test body_centered_lattice_constants ≈ expected_body_centered_lattice_constants

    # Check conversion back to base-centering
    #
    # Note: when the body-centered unit cell is converted back to base-centering, a
    #       different unit cell is selected because the original base-centered unit cell
    #       had a larger value of a^2 + c^2.
    expected_base_centered_lattice_constants = MonoclinicLatticeConstants(
        a, b, a_body, π - asin(sin(β) / a_body * c)
    )
    @test convert_to_base_centering(body_centered_lattice_constants) ≈
        expected_base_centered_lattice_constants
end

@testset "convert_to_base_centering()" begin
    # --- Preparations

    # Construct basis vectors for body-centered unit cell
    a = 6
    b = 3
    c = 10
    β = 3π / 5
    body_centered_lattice_constants, _ = standardize(
        MonoclinicLatticeConstants(a, b, c, β), XtallographyUtils.BODY
    )

    # --- Exercise functionality and check results

    # Check conversion to base-centering
    base_centered_lattice_constants = convert_to_base_centering(
        body_centered_lattice_constants
    )

    a_base = sqrt(a^2 + c^2 + 2 * a * c * cos(β))
    c_base = a
    β_base = π - acos((a_base^2 + c_base^2 - c^2) / 2 / a_base / c_base)
    expected_base_centered_lattice_constants = MonoclinicLatticeConstants(
        a_base, b, c_base, β_base
    )
    @test base_centered_lattice_constants ≈ expected_base_centered_lattice_constants

    # Check conversion back to body-centering via standardize()
    standardized_lattice_constants, standardized_centering = standardize(
        base_centered_lattice_constants, XtallographyUtils.BASE
    )
    @test standardized_lattice_constants ≈ body_centered_lattice_constants
    @test standardized_centering == XtallographyUtils.BODY
end

@testset "reduced_cell()" begin
    # --- Preparations

    a = 2
    b = 3
    c = 5
    β = 4π / 7
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)
    basis_a, basis_b, basis_c = basis(lattice_constants)

    # --- Exercise functionality and check results

    # primitive unit cell defined by [basis_a, basis_b, basis_c]
    unit_cell = UnitCell(lattice_constants, XtallographyUtils.PRIMITIVE)

    expected_reduced_cell = reduced_cell(
        UnitCell(lattice_constants, XtallographyUtils.PRIMITIVE)
    )

    reduced_cell_ = reduced_cell(unit_cell)
    @test reduced_cell_.lattice_constants isa MonoclinicLatticeConstants
    @test volume(reduced_cell_) ≈ volume(unit_cell)
    @test reduced_cell_ ≈ expected_reduced_cell

    # primitive unit cell defined by linear combination of [basis_a, basis_b, basis_c]
    unit_cell = UnitCell(
        LatticeConstants(basis_a + basis_c, basis_b, basis_c), XtallographyUtils.PRIMITIVE
    )

    expected_reduced_cell = reduced_cell(
        UnitCell(lattice_constants, XtallographyUtils.PRIMITIVE)
    )

    reduced_cell_ = reduced_cell(unit_cell)
    @test reduced_cell_.lattice_constants isa MonoclinicLatticeConstants
    @test volume(reduced_cell_) ≈ volume(unit_cell)
    @test reduced_cell_ ≈ expected_reduced_cell

    # body-centered unit cell
    unit_cell = UnitCell(lattice_constants, XtallographyUtils.BODY)

    expected_reduced_cell = reduced_cell(
        UnitCell(
            LatticeConstants(basis_a, basis_b, 0.5 * (basis_a + basis_b + basis_c)),
            XtallographyUtils.PRIMITIVE,
        ),
    )

    reduced_cell_ = reduced_cell(unit_cell)
    @test reduced_cell_.lattice_constants isa TriclinicLatticeConstants
    @test volume(reduced_cell_) ≈ 0.5 * volume(unit_cell)
    @test reduced_cell_ ≈ expected_reduced_cell

    # base-centered unit cell
    unit_cell = UnitCell(lattice_constants, XtallographyUtils.BASE)

    expected_reduced_cell = reduced_cell(
        UnitCell(
            LatticeConstants(basis_a, 0.5 * (basis_a + basis_b), basis_c),
            XtallographyUtils.PRIMITIVE,
        ),
    )

    reduced_cell_ = reduced_cell(unit_cell)
    @test reduced_cell_.lattice_constants isa TriclinicLatticeConstants
    @test volume(reduced_cell_) ≈ 0.5 * volume(unit_cell)
    @test reduced_cell_ ≈ expected_reduced_cell

    # equivalent body-centered and base-centered monoclinic unit cells
    base_centered_unit_cell = UnitCell(lattice_constants, XtallographyUtils.BASE)
    body_centered_basis_a = basis_a + basis_c
    body_centered_basis_b = basis_b
    body_centered_basis_c = basis_c
    body_centered_unit_cell = UnitCell(
        MonoclinicLatticeConstants(
            norm(body_centered_basis_a),
            norm(body_centered_basis_b),
            norm(body_centered_basis_c),
            π - acos(
                dot(body_centered_basis_a, body_centered_basis_c) /
                norm(body_centered_basis_a) / norm(body_centered_basis_c),
            ),
        ),
        XtallographyUtils.BODY,
    )

    @test base_centered_unit_cell.lattice_constants isa MonoclinicLatticeConstants
    @test body_centered_unit_cell.lattice_constants isa MonoclinicLatticeConstants

    @test reduced_cell(base_centered_unit_cell) ≈ reduced_cell(body_centered_unit_cell)

    # face-centered unit cell (equivalent to smaller body-centered unit cell)
    face_centered_unit_cell = UnitCell(lattice_constants, XtallographyUtils.FACE)
    body_centered_basis_a = 0.5 * (basis_a + basis_c)
    body_centered_basis_b = basis_b
    body_centered_basis_c = 0.5 * (basis_a - basis_c)
    body_centered_unit_cell = UnitCell(
        MonoclinicLatticeConstants(
            norm(body_centered_basis_a),
            norm(body_centered_basis_b),
            norm(body_centered_basis_c),
            acos(
                dot(body_centered_basis_a, body_centered_basis_c) /
                norm(body_centered_basis_a) / norm(body_centered_basis_c),
            ),
        ),
        XtallographyUtils.BODY,
    )

    reduced_face_centered_unit_cell = reduced_cell(face_centered_unit_cell)
    reduced_body_centered_unit_cell = reduced_cell(body_centered_unit_cell)

    @test face_centered_unit_cell.lattice_constants isa MonoclinicLatticeConstants
    @test body_centered_unit_cell.lattice_constants isa MonoclinicLatticeConstants

    @test reduced_face_centered_unit_cell ≈ reduced_body_centered_unit_cell
    @test volume(reduced_body_centered_unit_cell) ≈ 0.25 * volume(face_centered_unit_cell)
    @test volume(reduced_face_centered_unit_cell) ≈ 0.25 * volume(face_centered_unit_cell)
end

@testset "is_equivalent_unit_cell(::UnitCell, ::UnitCell)" begin
    # --- Preparations

    a = 2
    b = 3
    c = 5
    β = 5π / 7
    lattice_constants = MonoclinicLatticeConstants(a, b, c, β)
    basis_a, basis_b, basis_c = basis(lattice_constants)

    # --- Tests

    # equivalent monoclinic and triclinic unit cells
    monoclinic_unit_cell = UnitCell(lattice_constants, XtallographyUtils.PRIMITIVE)
    triclinic_unit_cell = UnitCell(
        LatticeConstants(basis_a, basis_b, basis_c; identify_lattice_system=false),
        XtallographyUtils.PRIMITIVE,
    )
    @test is_equivalent_unit_cell(monoclinic_unit_cell, triclinic_unit_cell)

    # body-centered unit cell
    body_centered_unit_cell = UnitCell(lattice_constants, XtallographyUtils.BODY)
    primitive_unit_cell = UnitCell(
        LatticeConstants(
            basis_a,
            basis_b,
            0.5 * (basis_a + basis_b + basis_c);
            identify_lattice_system=false,
        ),
        XtallographyUtils.PRIMITIVE,
    )
    @test is_equivalent_unit_cell(body_centered_unit_cell, primitive_unit_cell)

    # equivalent base-centered and body-centered monoclinic unit cells
    base_centered_unit_cell = UnitCell(lattice_constants, XtallographyUtils.BASE)
    body_centered_unit_cell = UnitCell(
        LatticeConstants(
            basis_a + basis_c, basis_b, basis_c; centering=XtallographyUtils.BODY
        ),
        XtallographyUtils.BODY,
    )
    @test is_equivalent_unit_cell(base_centered_unit_cell, body_centered_unit_cell)
end

@testset "is_equivalent_unit_cell(::LatticeConstants, ::LatticeConstants)" begin
    # --- Preparations

    a_ref = 6
    b_ref = 10
    c_ref = 8
    β_ref = π / 3
    lattice_constants_ref = MonoclinicLatticeConstants(a_ref, b_ref, c_ref, β_ref)

    # --- Exercise functionality and check results

    # Equivalent unit cell #1
    a = a_ref
    b = b_ref
    c = sqrt(a_ref^2 + c_ref^2 - 2 * a_ref * c_ref * cos(β_ref))
    β = asin(sin(β_ref) / c * c_ref)
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test is_equivalent_unit_cell(lattice_constants_test, lattice_constants_ref)

    # Equivalent unit cell #2
    a = sqrt(a_ref^2 + c_ref^2 - 2 * a_ref * c_ref * cos(β_ref))
    b = b_ref
    c = c_ref
    β = asin(sin(β_ref) / a * a_ref)
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test is_equivalent_unit_cell(lattice_constants_test, lattice_constants_ref)

    # Equivalent unit cell #3
    a = a_ref
    b = b_ref
    c = sqrt(a_ref^2 + c_ref^2 + 2 * a_ref * c_ref * cos(β_ref))
    β = asin(sin(β_ref) / c * c_ref)
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test is_equivalent_unit_cell(lattice_constants_test, lattice_constants_ref)

    # Supercell: b multiple of b_ref
    a = a_ref
    b = 3 * b_ref
    c = c_ref
    β = β_ref
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test !is_equivalent_unit_cell(lattice_constants_test, lattice_constants_ref)

    # Supercell: c multiple of c_ref
    a = a_ref
    b = b_ref
    c = 5 * c_ref
    β = β_ref
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test !is_equivalent_unit_cell(lattice_constants_test, lattice_constants_ref)

    # Supercell: c equal to diagonal from unit cell twice as high in c_ref direction
    a = a_ref
    b = b_ref
    c = sqrt(a_ref^2 + (2 * c_ref)^2 - 2 * a_ref * (2 * c_ref) * cos(β_ref))
    β = asin(sin(β_ref) / c * (2 * c_ref))
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test !is_equivalent_unit_cell(lattice_constants_test, lattice_constants_ref)

    # test unit cell and reference unit cell are for different lattice systems
    lattice_constants_test = CubicLatticeConstants(1)
    @test !is_equivalent_unit_cell(lattice_constants_test, lattice_constants_ref)
end

@testset "is_supercell(): valid arguments" begin
    # --- Preparations

    a_ref = 6
    b_ref = 10
    c_ref = 8
    β_ref = π / 3
    lattice_constants_ref = MonoclinicLatticeConstants(a_ref, b_ref, c_ref, β_ref)

    # --- Exercise functionality

    # Supercell: b multiple of b_ref
    a = a_ref
    b = 3 * b_ref
    c = c_ref
    β = β_ref
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test is_supercell(lattice_constants_test, lattice_constants_ref)

    # Supercell: c multiple of c_ref
    a = a_ref
    b = b_ref
    c = 5 * c_ref
    β = β_ref
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test !is_supercell(lattice_constants_test, lattice_constants_ref)
    @test is_supercell(lattice_constants_test, lattice_constants_ref; max_index=5)

    # Supercell: c equal to diagonal from unit cell twice as high in c_ref direction
    a = a_ref
    b = b_ref
    c = sqrt(a_ref^2 + (2 * c_ref)^2 - 2 * a_ref * (2 * c_ref) * cos(β_ref))
    β = asin(sin(β_ref) / c * (2 * c_ref))
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test is_supercell(lattice_constants_test, lattice_constants_ref)

    # Supercell: basis formed from both diagonals of parallelogram formed by a_ref
    #            and c_ref
    a = sqrt(a_ref^2 + c_ref^2 - 2 * a_ref * c_ref * cos(β_ref))
    b = b_ref
    c = sqrt(a_ref^2 + c_ref^2 + 2 * a_ref * c_ref * cos(β_ref))
    β = asin(sin(β_ref) / a * a_ref) + asin(sin(β_ref) / c * a_ref)
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test is_supercell(lattice_constants_test, lattice_constants_ref)

    # Equivalent unit cell
    a = a_ref
    b = b_ref
    c = sqrt(a_ref^2 + c_ref^2 - 2 * a_ref * c_ref * cos(β_ref))
    β = asin(sin(β_ref) / c * c_ref)
    lattice_constants_test = MonoclinicLatticeConstants(a, b, c, β)

    @test !is_supercell(lattice_constants_test, lattice_constants_ref)
end

@testset "is_supercell(): invalid arguments" begin
    # --- Preparations

    a_ref = 6
    b_ref = 10
    c_ref = 8
    β_ref = π / 3
    lattice_constants_ref = MonoclinicLatticeConstants(a_ref, b_ref, c_ref, β_ref)

    a_test = a_ref
    b_test = 3 * b_ref
    c_test = c_ref
    β_test = β_ref
    lattice_constants_test = MonoclinicLatticeConstants(a_test, b_test, c_test, β_test)

    # --- Exercise functionality and check results

    # ------ `tol`

    # tol = 0
    local error, error_message
    try
        is_supercell(lattice_constants_test, lattice_constants_ref; tol=0)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `tol` must be positive"
    @test startswith(error_message, expected_error)

    # tol < 0
    local error, error_message
    try
        is_supercell(lattice_constants_test, lattice_constants_ref; tol=-0.1)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `tol` must be positive"
    @test startswith(error_message, expected_error)

    # ------ `max_index`

    # max_index = 0
    local error, error_message
    try
        is_supercell(lattice_constants_test, lattice_constants_ref; max_index=0)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `max_index` must be positive"
    @test startswith(error_message, expected_error)

    # max_index < 0
    local error, error_message
    try
        is_supercell(lattice_constants_test, lattice_constants_ref; max_index=-3)
    catch error
        bt = catch_backtrace()
        error_message = sprint(showerror, error, bt)
    end

    @test error isa ArgumentError

    expected_error = "ArgumentError: `max_index` must be positive"
    @test startswith(error_message, expected_error)
end