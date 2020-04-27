#!/usr/bin/env python
# encoding: utf-8
###############################################################################
#                                                                             #
#    kESI                                                                     #
#                                                                             #
#    Copyright (C) 2020 Jakub M. Dzik (Laboratory of Neuroinformatics;        #
#    Nencki Institute of Experimental Biology of Polish Academy of Sciences)  #
#                                                                             #
#    This software is free software: you can redistribute it and/or modify    #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    This software is distributed in the hope that it will be useful,         #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with this software.  If not, see http://www.gnu.org/licenses/.     #
#                                                                             #
###############################################################################

import warnings
import unittest

import numpy as np

try:
    from ._common import TestCase, SpyKernelSolverClass
    # When run as script raises:
    #  - `ModuleNotFoundError(ImportError)` (Python 3.6-7), or
    #  - `SystemError` (Python 3.3-5), or
    #  - `ValueError` (Python 2.7).

except (ImportError, SystemError, ValueError):
    from _common import TestCase, SpyKernelSolverClass

import kesi._verbose as verbose


class TestCrossKernelReconstructor(TestCase):
    KERNEL = None
    MEASURED = [13, 37]
    CROSS_KERNEL = [[1, 3],
                    [2, 2],
                    [3, 1]]

    def setUp(self):
        self.kernel_solver = SpyKernelSolverClass()
        self.reconstructor = verbose._VerboseFunctionalFieldReconstructorBase._CrossKernelReconstructor(
                  self.kernel_solver(self.KERNEL),
                  self.CROSS_KERNEL)

    def testReconstructsSingleMeasurements(self):
        self.checkCall([1, 1])

    def testReconstructsSingleMeasurementsWithRegularization(self):
        self.checkCall([1, 1], regularization_parameter=1)

    def testReconstructsSerialMeasurements(self):
        self.checkCall([[1, 1],
                        [-1, 2]])

    def test_leave_one_out_methodWithoutRegularization(self):
        self.check_leave_one_out_method()

    def test_leave_one_out_methodWithRegularization(self):
        self.check_leave_one_out_method(regularization_parameter=1)

    def checkCall(self, solution, regularization_parameter=None):
        self.kernel_solver.set_solution(solution)
        expected = np.matmul(self.CROSS_KERNEL, solution)
        self.checkArrayLikeAlmostEqual(expected,
                                       (self.reconstructor(self.MEASURED)
                                        if regularization_parameter is None
                                        else self.reconstructor(self.MEASURED,
                                                                regularization_parameter=regularization_parameter)))
        self.assertEqual(1, self.kernel_solver.call_counter['__call__'])
        self.check_rhs_and_regularization_parameter_arguments(regularization_parameter)

    def check_rhs_and_regularization_parameter_arguments(self, regularization_parameter):
        self.checkArrayLikeAlmostEqual(self.MEASURED,
                                       self.kernel_solver.rhs)
        if regularization_parameter is None:
            self.assertIsNone(self.kernel_solver.regularization_parameter)
        else:
            self.assertEqual(regularization_parameter,
                             self.kernel_solver.regularization_parameter)

    def check_leave_one_out_method(self, regularization_parameter=None):
        result = np.random.random(2)
        self.kernel_solver.set_leave_one_out_errors(result)
        self.checkArrayAlmostEqual(result,
                                   (self.reconstructor.leave_one_out(self.MEASURED)
                                    if regularization_parameter is None
                                    else self.reconstructor.leave_one_out(self.MEASURED,
                                                                          regularization_parameter=regularization_parameter)))
        self.assertEqual(1, self.kernel_solver.call_counter['leave_one_out'])
        self.check_rhs_and_regularization_parameter_arguments(regularization_parameter)


class TestLegacyCrossKernelReconstructor(unittest.TestCase):
    def testDeprecationWarning(self):
        with warnings.catch_warnings(record=True) as w:
            warnings.simplefilter("always")

            verbose._CrossKernelReconstructor(
                SpyKernelSolverClass([[]]),
                [[]])

            self.assertEqual(1, len(w))
            self.assertTrue(issubclass(w[-1].category,
                                       DeprecationWarning))



if __name__ == '__main__':
    unittest.main()
