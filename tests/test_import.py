def test_import():
    try:
        import app.agente
        assert True
    except ImportError:
        assert False
