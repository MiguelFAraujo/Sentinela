"""Sentinela — Unit Tests."""

import unittest
from unittest.mock import patch, MagicMock


class TestConfig(unittest.TestCase):
    """Configuration tests."""

    def test_import_config(self):
        from app.config import MODEL, OLLAMA_HOST, VERSION

        self.assertIsInstance(MODEL, str)
        self.assertIsInstance(OLLAMA_HOST, str)
        self.assertEqual(VERSION, "3.1.1")

    def test_ollama_api_url(self):
        from app.config import OLLAMA_API_URL

        self.assertTrue(OLLAMA_API_URL.endswith("/api/generate"))


class TestScanner(unittest.TestCase):
    """Scanner module tests."""

    def test_import_scanner(self):
        from app.scanner import get_local_ip, smart_audit

        self.assertTrue(callable(get_local_ip))
        self.assertTrue(callable(smart_audit))

    def test_get_local_ip_returns_string(self):
        from app.scanner import get_local_ip

        ip = get_local_ip()
        self.assertIsInstance(ip, str)
        self.assertRegex(ip, r"^\d+\.\d+\.\d+\.\d+$")


class TestLLM(unittest.TestCase):
    """LLM module tests."""

    def test_import_llm(self):
        from app.llm import analyze_with_ai

        self.assertTrue(callable(analyze_with_ai))

    @patch("app.llm.requests.post")
    def test_analyze_with_ai_success(self, mock_post):
        from app.llm import analyze_with_ai

        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"response": "Test analysis OK"}
        mock_response.raise_for_status = MagicMock()
        mock_post.return_value = mock_response

        result = analyze_with_ai("Port 80 open")
        self.assertEqual(result, "Test analysis OK")

    @patch("app.llm.requests.post")
    def test_analyze_with_ai_timeout(self, mock_post):
        import requests
        from app.llm import analyze_with_ai

        mock_post.side_effect = requests.exceptions.Timeout()

        result = analyze_with_ai("Port 80 open")
        self.assertIn("Timeout", result)

    @patch("app.llm.requests.post")
    def test_analyze_with_ai_connection_error(self, mock_post):
        import requests
        from app.llm import analyze_with_ai

        mock_post.side_effect = requests.exceptions.ConnectionError()

        result = analyze_with_ai("Port 80 open")
        self.assertIn("Connection", result)


class TestAgent(unittest.TestCase):
    """Main agent tests."""

    def test_import_agent(self):
        from app.agente import app, run_scan, main

        self.assertIsNotNone(app)
        self.assertTrue(callable(run_scan))
        self.assertTrue(callable(main))

    def test_fastapi_routes(self):
        from app.agente import app

        routes = [r.path for r in app.routes]
        self.assertIn("/", routes)
        self.assertIn("/health", routes)
        self.assertIn("/scan", routes)


if __name__ == "__main__":
    unittest.main()
