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
Functions that support computations specific to orthorhombic lattices
"""
# --- Imports

# Standard library
using Logging

# --- Exports

# Types
export Orthorhombic
export OrthorhombicLatticeConstants

# Functions

# --- Types

"""
    Orthorhombic

Type representing the orthorhombic lattice system

Supertype: [`LatticeSystem`](@ref)
"""
struct Orthorhombic <: LatticeSystem end

"""
    OrthorhombicLatticeConstants

Lattice constants for an orthorhombic unit cell

Fields
======
* `a`, `b`, `c`: lengths of the edges of the unit cell

!!! note
    By convention, edge lengths of the unit cell are ordered so that `a` <= `b` <= `c`.

Supertype: [`LatticeConstants`](@ref)
"""
struct OrthorhombicLatticeConstants <: LatticeConstants
    # Fields
    a::Float64
    b::Float64
    c::Float64

    """
    Construct a set of orthorhombic lattice constants.
    """
    function OrthorhombicLatticeConstants(a::Real, b::Real, c::Real)

        # --- Enforce constraints

        if a <= 0
            throw(ArgumentError("`a` must be positive"))
        end

        if b <= 0
            throw(ArgumentError("`b` must be positive"))
        end

        if c <= 0
            throw(ArgumentError("`c` must be positive"))
        end

        # --- Construct and return new OrthorhombicLatticeConstants

        return new(a, b, c)
    end
end

# --- Functions/Methods

# ------ LatticeConstants functions

function isapprox(
    x::OrthorhombicLatticeConstants,
    y::OrthorhombicLatticeConstants;
    atol::Real=0,
    rtol::Real=atol > 0 ? 0 : √eps(),
)
    return isapprox(x.a, y.a; atol=atol, rtol=rtol) &&
           isapprox(x.b, y.b; atol=atol, rtol=rtol) &&
           isapprox(x.c, y.c; atol=atol, rtol=rtol)
end

function lattice_system(::OrthorhombicLatticeConstants)
    return Orthorhombic
end

function standardize(lattice_constants::OrthorhombicLatticeConstants, centering::Centering)
    # --- Check arguments

    standardize_arg_checks(lattice_constants, centering)

    # --- Preparations

    # Extract lattice constants
    a = lattice_constants.a
    b = lattice_constants.b
    c = lattice_constants.c

    # --- Standardize lattice constants

    if centering == BaseCentered()
        return OrthorhombicLatticeConstants(sort([a, b])..., c), BaseCentered()
    end

    # all other centerings
    return OrthorhombicLatticeConstants(sort([a, b, c])...), centering
end

# ------ Unit cell computations

function basis(lattice_constants::OrthorhombicLatticeConstants)
    # Construct basis
    basis_a = Vector{Float64}([lattice_constants.a, 0, 0])
    basis_b = Vector{Float64}([0, lattice_constants.b, 0])
    basis_c = Vector{Float64}([0, 0, lattice_constants.c])

    return basis_a, basis_b, basis_c
end

function volume(lattice_constants::OrthorhombicLatticeConstants)
    # Compute volume
    return lattice_constants.a * lattice_constants.b * lattice_constants.c
end

function surface_area(lattice_constants::OrthorhombicLatticeConstants)
    # Get lattice constants
    a = lattice_constants.a
    b = lattice_constants.b
    c = lattice_constants.c

    # Compute surface area
    return 2 * (a * b + b * c + c * a)
end

function conventional_cell(::Orthorhombic, unit_cell::UnitCell)
    # --- Check arguments

    conventional_cell_arg_checks(unit_cell)

    # --- Preparations

    # Get standardized lattice constants and centering
    lattice_constants, centering = standardize(
        unit_cell.lattice_constants, unit_cell.centering
    )

    # Get lattice constants and centering
    a = lattice_constants.a
    b = lattice_constants.b
    c = lattice_constants.c

    # --- Compute IUCr conventional cell

    # Check limiting cases
    if centering == Primitive()
        # Tetragonal, primitive
        if a ≈ b
            @debug "oP --> tP"
            return conventional_cell(
                UnitCell(TetragonalLatticeConstants(a, c), Primitive())
            )
        elseif b ≈ c
            @debug "oP --> tP"
            return conventional_cell(
                UnitCell(TetragonalLatticeConstants(c, a), Primitive())
            )
        end

    elseif centering == BodyCentered()
        # Tetragonal, body-centered
        if a ≈ b
            @debug "oI --> tI"
            return conventional_cell(
                UnitCell(TetragonalLatticeConstants(a, c), BodyCentered())
            )
        elseif b ≈ c
            @debug "oI --> tI"
            return conventional_cell(
                UnitCell(TetragonalLatticeConstants(c, a), BodyCentered())
            )
        end

    elseif centering == FaceCentered()
        # Tetragonal, body-centered
        if a ≈ b
            @debug "oF --> tI"
            return conventional_cell(
                UnitCell(
                    TetragonalLatticeConstants(a * SIN_PI_OVER_FOUR, c), BodyCentered()
                ),
            )
        elseif b ≈ c
            @debug "oF --> tI"
            return conventional_cell(
                UnitCell(
                    TetragonalLatticeConstants(c * SIN_PI_OVER_FOUR, a), BodyCentered()
                ),
            )
        end

    elseif centering == BaseCentered()
        if a ≈ b
            # Tetragonal, primitive
            @debug "oC --> tP"
            return conventional_cell(
                UnitCell(TetragonalLatticeConstants(a * SIN_PI_OVER_FOUR, c), Primitive())
            )

        elseif b ≈ 2 * a * SIN_PI_OVER_THREE
            # Hexagonal, primitive
            @debug "oC --> hP"
            return conventional_cell(UnitCell(HexagonalLatticeConstants(a, c), Primitive()))
        end
    end

    # Not a limiting case, so return unit cell with standardized lattice constants
    return UnitCell(lattice_constants, centering)
end

function is_supercell(
    lattice_constants_test::OrthorhombicLatticeConstants,
    lattice_constants_ref::OrthorhombicLatticeConstants;
    tol::Real=1e-3,
    max_index::Integer=3,
)
    # --- Check arguments

    # TODO
    return true
end
