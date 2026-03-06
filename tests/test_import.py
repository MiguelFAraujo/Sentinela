"""Testes do Sentinela."""

import unittest
from unittest.mock import patch, MagicMock


class TestConfig(unittest.TestCase):
    """Testes das configurações."""

    def test_import_config(self):
        from app.config import MODELO, OLLAMA_HOST, VERSION

        self.assertIsInstance(MODELO, str)
        self.assertIsInstance(OLLAMA_HOST, str)
        self.assertEqual(VERSION, "3.1.0")

    def test_ollama_api_url(self):
        from app.config import URL_OLLAMA_API

        self.assertTrue(URL_OLLAMA_API.endswith("/api/generate"))


class TestScanner(unittest.TestCase):
    """Testes do módulo scanner."""

    def test_import_scanner(self):
        from app.scanner import pegar_ip_local, auditoria_inteligente

        self.assertTrue(callable(pegar_ip_local))
        self.assertTrue(callable(auditoria_inteligente))

    def test_pegar_ip_local_retorna_string(self):
        from app.scanner import pegar_ip_local

        ip = pegar_ip_local()
        self.assertIsInstance(ip, str)
        self.assertRegex(ip, r"^\d+\.\d+\.\d+\.\d+$")


class TestLLM(unittest.TestCase):
    """Testes do módulo LLM."""

    def test_import_llm(self):
        from app.llm import analisar_com_ia

        self.assertTrue(callable(analisar_com_ia))

    @patch("app.llm.requests.post")
    def test_analisar_com_ia_sucesso(self, mock_post):
        from app.llm import analisar_com_ia

        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"response": "Análise de teste OK"}
        mock_response.raise_for_status = MagicMock()
        mock_post.return_value = mock_response

        result = analisar_com_ia("Porta 80 aberta")
        self.assertEqual(result, "Análise de teste OK")

    @patch("app.llm.requests.post")
    def test_analisar_com_ia_timeout(self, mock_post):
        import requests
        from app.llm import analisar_com_ia

        mock_post.side_effect = requests.exceptions.Timeout()

        result = analisar_com_ia("Porta 80 aberta")
        self.assertIn("Timeout", result)

    @patch("app.llm.requests.post")
    def test_analisar_com_ia_conexao(self, mock_post):
        import requests
        from app.llm import analisar_com_ia

        mock_post.side_effect = requests.exceptions.ConnectionError()

        result = analisar_com_ia("Porta 80 aberta")
        self.assertIn("Conexão", result)


class TestAgente(unittest.TestCase):
    """Testes do agente principal."""

    def test_import_agente(self):
        from app.agente import app, executar_varredura, main

        self.assertIsNotNone(app)
        self.assertTrue(callable(executar_varredura))
        self.assertTrue(callable(main))

    def test_fastapi_routes(self):
        from app.agente import app

        routes = [r.path for r in app.routes]
        self.assertIn("/", routes)
        self.assertIn("/health", routes)
        self.assertIn("/scan", routes)


if __name__ == "__main__":
    unittest.main()
