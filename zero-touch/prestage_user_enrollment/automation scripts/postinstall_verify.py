import unittest
import os
import os.path
import re


class text_POST(unittest.TestCase):
    script = ""
    criteria_strings = [
        "ENROLLMENT_USER=",
        "ENROLLMENT_USER_PASSWORD="
    ]

    def var_str(self, string, regexGrp):
        '''test that string var exists'''
        regex = "^(%s)(\'(.*?)\')$" % string
        with open(text_POST.script, "r") as file:
            match_list = []
            i = 0
            for line in file:
                i += 1
                match = re.search(regex, line)
                if match:
                    match_list.append(line)
        result = re.match(regex, match_list[0])
        strResult = result[regexGrp]
        self.assertRegex(match_list[0], regex)
        self.assertIsNot(len(strResult), 0, "{} variable should not be empty".format(string))
        self.assertTrue(type(strResult) is str)

    def test_a1_existence(self):
        '''Test File Path'''
        result = os.path.exists(text_POST.script)
        self.assertTrue(result)

    def test_b1_valid_strings(self):
        '''Testing postinstall script User Vars'''
        for i in self.criteria_strings:
            self.var_str(i, 3)


if __name__ == "__main__":
    unittest.main()
