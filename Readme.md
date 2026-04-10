# Ambiente FIWARE - Plataforma IoT e Cidades Inteligentes

Este repositório contém a infraestrutura baseada em Docker Compose para subir um ambiente FIWARE completo. A arquitetura está configurada para receber dados via MQTT, processá-los no Context Broker, armazenar o histórico e visualizá-los em dashboards.

## 🏗️ Arquitetura e Serviços

O ambiente está dividido em três camadas principais:

### 1. Bancos de Dados e Infraestrutura
* **MongoDB (`mongo-db`)**: Banco de dados NoSQL utilizado pelo Orion Context Broker e IoT Agent para armazenar entidades, subscrições e dados de provisionamento.
* **CrateDB (`cratedb`)**: Banco de dados de série temporal distribuído, utilizado pelo QuantumLeap para armazenar o histórico das entidades.
* **Redis (`redis-db`)**: Banco de dados em memória utilizado pelo QuantumLeap para cache.
* **Mosquitto (`mosquitto`)**: Broker MQTT padrão da indústria para receber e rotear as mensagens dos dispositivos IoT.

### 2. FIWARE Generic Enablers (GEs)
* **Orion Context Broker (`orion`)**: O coração da plataforma FIWARE. Gerencia todo o ciclo de vida das informações de contexto em tempo real.
* **QuantumLeap (`quantumleap`)**: Componente responsável por persistir dados históricos do Orion em bancos de séries temporais (neste caso, CrateDB).
* **IoT Agent MQTT (`iot-agent-mqtt`)**: Traduz protocolos IoT (especificamente MQTT com payload UltraLight ou JSON) para a linguagem de contexto do Orion (NGSI).

### 3. Visualização
* **Grafana (`grafana`)**: Plataforma de analytics e monitoramento utilizada para criar dashboards visuais consultando os dados históricos salvos no CrateDB.

---

## ⚙️ Pré-requisitos

Para rodar este ambiente, você precisará ter instalados na sua máquina:
* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/)
// A versão mais recente do Docker Desktop já vem com o Docker Compose instalado, não precisa instalar por fora

---

## 🚀 Comandos Necessários para Rodar o Ambiente

Abra o terminal no mesmo diretório onde o arquivo `docker-compose.yml` está localizado e utilize os comandos abaixo.

### ⚠️ Configurações Adicionais
Arquivo de Configuração MQTT: Certifique-se de que o arquivo ./mosquitto.conf referenciado no docker-compose exista no mesmo diretório antes de subir o ambiente. Caso contrário, o serviço mosquitto apresentará erro ao montar o volume. Exemplo básico de mosquitto.conf para testes locais:
Snippet de código
allow_anonymous true
listener 1883
protocol mqtt
listener 9001
protocol websockets


Para criar, ultilize o seguinte comando no terminal:
```bash
echo -e "allow_anonymous true\nlistener 1883\nprotocol mqtt\nlistener 9001\nprotocol websockets" > mosquitto.conf
```

### Iniciar a plataforma
Para fazer o build (se necessário) e iniciar todos os contêineres em segundo plano (modo detached), execute:


```bash
docker-compose up -d  // Versão mais antiga do Docker Compose
docker compose up -d  // Versão mais recente do Docker Compose
```

### Verificar o status dos serviços
Para confirmar se todos os contêineres estão rodando corretamente:

```bash
docker-compose ps  // Versão mais antiga do Docker Compose
docker compose ps  // Versão mais recente do Docker Compose
```

### Acompanhar os logs
Para visualizar os logs em tempo real de todos os serviços (útil para debugar erros na inicialização ou no tráfego MQTT):

```bash
docker-compose logs -f  // Versão mais antiga do Docker Compose
docker compose logs -f  // Versão mais recente do Docker Compose
```
Para interromper essa transmissão e retornar o controle do terminal para você, basta pressionar no seu teclado:
```bash
Ctrl + C
```

(Dica: Para ver os logs de um serviço específico, adicione o nome dele ao final, ex: docker-compose logs -f orion)
### Parar e remover a plataforma
Para parar todos os contêineres e remover as redes criadas pelo docker-compose (sem deletar os volumes):

```bash
docker-compose down  // Versão mais antiga do Docker Compose
docker compose down  // Versão mais recente do Docker Compose
```

## 🌐 Portas e Pontos de Acesso

Após iniciar a plataforma, os seguintes serviços estarão disponíveis na sua máquina local (`localhost`):

| Serviço | Porta Exposta | Descrição / Rota de Acesso |
| :--- | :--- | :--- |
| **Mosquitto (MQTT TCP)** | `1883` | Porta padrão para publicação de telemetria via hardware e sensores físicos. |
| **Mosquitto (WebSockets)** | `9001` | Porta para conexões MQTT diretas via navegadores de internet (dashboards web). |
| **Orion Context Broker** | `1026` | API central do FIWARE (ex: `http://localhost:1026/v2/entities`). |
| **IoT Agent (Northbound)** | `4041` | Endpoint da API para provisionamento de dispositivos e grupos IoT. |
| **QuantumLeap** | `8668` | API de consulta e inserção de dados históricos espaço-temporais. |
| **CrateDB (Admin UI)** | `4200` | Interface web do banco de dados relacional distribuído (`http://localhost:4200`). |
| **Grafana** | `3000` | Interface de criação e visualização de dashboards (`http://localhost:3000`). |
| **MongoDB** | `27018` | Acesso direto ao banco de dados NoSQL (porta exposta alterada para evitar conflitos com o localhost). |

