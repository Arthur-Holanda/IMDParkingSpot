import time
import random
import paho.mqtt.client as mqtt

# 1. Configurações Globais
BROKER = "localhost"
PORT = 1883
API_KEY = "imdparking_key"

# 2. Definição do nosso universo simulado
vagas = ["vaga001", "vaga002", "vaga003"]
placas_suspeitas = ["RNX-9999", "ABC-1234", "XYZ-5678"]

# 3. Conexão com o Mosquitto (Sintaxe v1.6.1)
client = mqtt.Client()
client.connect(BROKER, PORT, 60)

print("Iniciando simulador do estacionamento... (Pressione Ctrl+C para parar)")

# 4. Loop contínuo de simulação
try:
    while True:
        for vaga in vagas:
            # Lógica: Sorteia se a vaga está ocupada ou não
            ocupada = random.choice([True, False])
            
            if ocupada:
                status = "Ocupada"
                # Se ocupada, tem 20% chance de ser uma infração
                infracao = random.choice([True] + [False] * 4)
                
                if infracao:
                    alarme = "true"
                    placa = random.choice(placas_suspeitas)
                else:
                    alarme = "false"
                    placa = "OK"
            else:
                status = "Livre"
                alarme = "false"
                placa = "sem_placa"
                
            # Montagem do payload leve (UltraLight)
            payload = f"s|{status}|a|{alarme}|p|{placa}"
            topico = f"/{API_KEY}/{vaga}/attrs"
            
            # Disparo da mensagem
            client.publish(topico, payload)
            print(f"[{vaga}] -> Status: {status} | Alarme: {alarme} | Placa: {placa}")
            
            # Pequena pausa entre as leituras dos sensores
            time.sleep(2)
            
except KeyboardInterrupt:
    print("\nSimulador encerrado.")
    client.disconnect()