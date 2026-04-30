#!/bin/bash

# Configurações de Rede e Cabeçalhos
ORION_URL="http://localhost:1026"
IOTA_URL="http://localhost:4041"
SERVICE="imdparking"
SERVICE_PATH="/"

echo "--- Iniciando Provisionamento do IMDParkingSpot ---"

# 1. Criar o Service Group no IoT Agent
# Define a chave de segurança e o tipo de entidade padrão
echo "1/3: Criando Service Group..."
curl -iX POST "$IOTA_URL/iot/services" \
  -H "Content-Type: application/json" \
  -H "fiware-service: $SERVICE" \
  -H "fiware-servicepath: $SERVICE_PATH" \
  -d '{
 "services": [
   {
     "apikey":      "imdparking_key",
     "cbroker":     "http://fiware-orion:1026",
     "entity_type": "ParkingSpot",
     "resource":    "/iot/d"
   }
 ]
}'

# 2. Provisionar os Dispositivos (Vagas)
# Mapeia os atributos curtos (s, a, p) para o Orion
echo -e "\n2/3: Provisionando vagas (001, 002, 003)..."
for i in 001 002 003
do
    curl -iX POST "$IOTA_URL/iot/devices" \
      -H "Content-Type: application/json" \
      -H "fiware-service: $SERVICE" \
      -H "fiware-servicepath: $SERVICE_PATH" \
      -d '{
     "devices": [
       {
         "device_id":   "vaga'$i'",
         "entity_name": "ParkingSpot:vaga'$i'",
         "entity_type": "ParkingSpot",
         "protocol":    "PDI-IoTA-UltraLight",
         "transport":   "MQTT",
         "attributes": [
           { "object_id": "s", "name": "s", "type": "Text" },
           { "object_id": "a", "name": "a", "type": "Boolean" },
           { "object_id": "p", "name": "p", "type": "Text" }
         ]
       }
     ]
    }'
done

# 3. Criar a Subscrição para Histórico (QuantumLeap)
# Garante que as mudanças sejam salvas no CrateDB
echo -e "\n3/3: Criando subscrição para persistência histórica..."
curl -iX POST "$ORION_URL/v2/subscriptions" \
  -H "Content-Type: application/json" \
  -H "fiware-service: $SERVICE" \
  -H "fiware-servicepath: $SERVICE_PATH" \
  -d '{
  "description": "Notificar QuantumLeap sobre alteracoes no ParkingSpot",
  "subject": {
    "entities": [
      {
        "idPattern": ".*",
        "type": "ParkingSpot"
      }
    ],
    "condition": {
      "attrs": ["s", "a", "p"]
    }
  },
  "notification": {
    "http": {
      "url": "http://fiware-quantumleap:8668/v2/notify"
    },
    "attrs": ["s", "a", "p"],
    "metadata": ["dateCreated", "dateModified"]
  }
}'

echo -e "\n--- Provisionamento Concluído com Sucesso! ---"