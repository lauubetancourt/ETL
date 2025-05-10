import yaml
from sqlalchemy import create_engine

# Cargar configuración desde config.yml
with open('config.yml', 'r') as f:
    config = yaml.safe_load(f)

# Crear URL para SQLAlchemy
def build_url(cfg):
    return f"{cfg['drivername']}://{cfg['user']}:{cfg['password']}@{cfg['host']}:{cfg['port']}/{cfg['dbname']}"

# Crear los engines
origen_url = build_url(config['ORIGEN'])
bodega_url = build_url(config['BODEGA'])

engine_origen = create_engine(origen_url)
engine_bodega = create_engine(bodega_url)

# Probar conexión
with engine_origen.connect() as conn:
    print("Conexión a ORIGEN exitosa:", conn)

with engine_bodega.connect() as conn:
    print("Conexión a BODEGA exitosa:", conn)
