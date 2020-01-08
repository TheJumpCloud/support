import unittest
import os
import os.path
import re


class text_PUE(unittest.TestCase):
    script = ""
    criteria_strs = [
        "YOUR_CONNECT_KEY=",
        "ENCRYPTED_KEY=",
        "DECRYPT_USER=",
        "DEP_ENROLLMENT_GROUP_ID=",
        "DEP_POST_ENROLLMENT_GROUP_ID=",
        "admin="

    ]
    criteria_bools = [
        "DELETE_ENROLLMENT_USERS=",
        "self_secret=",
        "self_passwd="
    ]
    criteria_selfid = [
        'self_ID="PE"',
        'self_ID="CE"',
        'self_ID="LN"'
    ]

    # test functions
    def var_str(self, string, regexGrp):
        '''test that string var exists'''
        regex = "^(%s)(\"(.*?)\")$" % string
        with open(text_PUE.script, "r") as file:
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

    def var_bool(self, string, regexGrp):
        '''test that string var exists'''
        regex = "^(%s)(.*?)$" % string
        with open(text_PUE.script, "r") as file:
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
        expected = [
            "true",
            "false"
        ]
        self.assertIn(strResult, expected,
                      "{} variable does not look like a bash boolean value".format(string))

    # actual tests
    def test_a1_existence(self):
        '''Test File Path'''
        result = os.path.exists(text_PUE.script)
        self.assertTrue(result)

    def test_d3(self):
        '''String Validation'''
        for i in self.criteria_strs:
            # print("TESTING : " + i)
            self.var_str(i, 3)
    
    def test_e1(self):
        '''Boolean Validation'''
        for i in self.criteria_bools:
            # print("TESTING : " + i)
            self.var_bool(i, 2)

    def test_f1(self):
        '''Test Self ID'''
        string = "self_ID="
        regex = "^(%s)(\"(.*?)\")$" % string
        with open(text_PUE.script, "r") as file:
            match_list = []
            i = 0
            for line in file:
                i += 1
                match = re.search(regex, line)
                if match:
                    match_list.append(line)
        self.assertIsNot(len(match_list), 0, "Variable not found with regex search")
        self.assertRegex(match_list[0], regex, "Variable not found with regex search")
        result = re.match(regex, match_list[0])
        strResult = result[3]
        expected = [
            "CE",
            "PE",
            "LN"
        ]
        self.assertIsNot(len(strResult), 0, "Variable definition was empty")
        self.assertIn(strResult, expected, "Expected values for self id, CE, PE or LN were not found")
        self.assertTrue(type(strResult) is str)


if __name__ == "__main__":
    unittest.main()
