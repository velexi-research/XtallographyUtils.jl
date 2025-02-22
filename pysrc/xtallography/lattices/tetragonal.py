# Copyright (c) 2024 Velexi Corporation
#
# Use of this software is governed by the Business Source License included
# in the LICENSE file and at www.mariadb.com/bsl11.
#
# Change Date: Four years from the date the Licensed Work is published
#
# Change License: Mozilla Public License 2.0
"""
The tetragonal module defines classes and methods specific to tetragonal lattices.
"""

# --- Imports

# Local packages/modules
from .. import _JL
from .core import LatticeSystem, Centering, UnitCell


# --- Classes


class TetragonalUnitCell(UnitCell):
    """
    Lattice constants for a tetragonal unit cell
    """

    # --- Initializer

    def __init__(self, a: float, c: float, centering: Centering = Centering.PRIMITIVE):
        """
        Initialize TetragonalUnitCell object.

        Parameters
        ----------
        `a`, `c`: lattice constants
        """
        # Check arguments
        if a <= 0:
            raise ValueError(f"`a` must be positive. (a={a})")

        if c <= 0:
            raise ValueError(f"`c` must be positive. (c={c})")

        # Initialize parent class
        super().__init__(LatticeSystem.TETRAGONAL, centering=centering)

        # Initialize lattice constants
        self._a = a
        self._c = c

    # --- Properties

    @property
    def a(self):
        """
        Return `a`.
        """
        return self._a

    @property
    def c(self):
        """
        Return `c`.
        """
        return self._c

    # --- Methods

    def to_julia(self):
        """
        Convert TetragonalUnitCell object to a Julia struct.
        """
        return _JL.TetragonalLatticeConstants(self.a, self.c)
