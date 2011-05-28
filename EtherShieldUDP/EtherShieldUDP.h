#ifndef EtherShieldUDP_h
#define EtherShieldUDP_h

#include "WProgram.h"
#include <EtherShield.h>

#define BUFFER_SIZE 550

class EtherShieldUDP
{

	private:
		EtherShield _es;	
		uint16_t 	_localPort;
		uint16_t 	_remotePort;
		uint8_t 	_destinationIP[4];
		int _dat_p;
	
	
	public:
		//uint16_t 	_dat_p;
		uint8_t 	_buffer[BUFFER_SIZE+1];
		EtherShieldUDP();
		int receiveTCP();
		String getReceivedString(int dat_p);
		void configure(uint8_t *mac, uint8_t *ip, uint16_t localPort, uint16_t remotePort);
		void sendBroadcast(String data);
		void receiveBroadcast();

};

#endif
