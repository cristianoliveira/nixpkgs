import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("brave_update", Path(__file__).with_name("update.py"))
update = importlib.util.module_from_spec(spec)
spec.loader.exec_module(update)


class RenderTests(unittest.TestCase):
    def test_renders_each_supported_platform(self):
        checksums = {system: "00" * 32 + "  asset" for system in update.ASSETS}
        result = update.render("1.2.3", checksums)
        self.assertIn('version = "1.2.3";', result)
        for system in update.ASSETS:
            self.assertIn(f"    {system} = {{", result)
        self.assertEqual(result.count("sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="), 4)

    def test_rejects_bad_version(self):
        with self.assertRaises(ValueError):
            update.render('1.2.3"; malicious', {})

    def test_rejects_invalid_checksum(self):
        checksums = {system: "00" * 32 for system in update.ASSETS}
        checksums["x86_64-linux"] = "bad"
        with self.assertRaises(ValueError):
            update.render("1.2.3", checksums)


if __name__ == "__main__":
    unittest.main()
