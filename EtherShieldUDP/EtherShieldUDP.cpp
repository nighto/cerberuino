#include "WProgram.h"
#include "EtherShieldUDP.h"
#include <EtherShield.h>

EtherShieldUDP::EtherShieldUDP() {}

void EtherShieldUDP::configure(uint8_t *mac, uint8_t *ip, uint16_t localPort, uint16_t remotePort)
{

	_localPort = localPort;
	_remotePort = remotePort;
	_destinationIP[0] = 255;
	_destinationIP[1] = 255;
	_destinationIP[2] = 255;
	_destinationIP[3] = 255;
  
  
	_es = EtherShield();

	// Initialise SPI interface
	_es.ES_enc28j60SpiInit();

	// initialize enc28j60
	_es.ES_enc28j60Init(mac);

	// init the ethernet/ip layer:
	_es.ES_init_ip_arp_udp_tcp(mac, ip, remotePort);
	
	
	
}

String EtherShieldUDP::getReceivedString(int dat_p) {
	String ret = "";
	
	for(int j=0;j<8;j++) {	
		ret+= (char)_buffer[dat_p + j];
	}
	
	return ret;
}

int EtherShieldUDP::receiveTCP() {
	// read packet, handle ping and wait for a tcp packet:
	
	for(int i=0;i<sizeof(_buffer);i++)
		_buffer[i] = 0;
	
	return _es.ES_packetloop_icmp_tcp(_buffer,_es.ES_enc28j60PacketReceive(BUFFER_SIZE, _buffer));
}

void EtherShieldUDP::sendBroadcast(String data) {
	_es.ES_send_udp_prepare(_buffer, _localPort, _destinationIP, _remotePort); 

	int datalen = data.length();
	
	int i = 0;
	while(i<6){
		_buffer[ETH_DST_MAC +i]= 0xff; // Broadcsat address
		i++;
	}
	  
	i=0;
	while(i<datalen){
		_buffer[UDP_DATA_P+i]=data[i];
		i++;
	}
	  
	_es.ES_send_udp_transmit(_buffer, datalen);
}

