using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Net.Sockets;
using System.Net;

namespace TesteUDP
{
    public partial class Form1 : Form
    {
        int listenPort = 11000;

        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            //Start
            backgroundWorker1.RunWorkerAsync();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            var text_to_send = textBox2.Text;

            IPAddress send_to_address = IPAddress.Broadcast;// IPAddress.Parse("10.0.0.9");
            IPEndPoint sending_end_point = new IPEndPoint(send_to_address, listenPort);

            using (Socket sending_socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp))
            {
                sending_socket.EnableBroadcast = true;

                //Send
                IPEndPoint groupEP = new IPEndPoint(IPAddress.Any, listenPort);

                // the socket object must have an array of bytes to send.
                // this loads the string entered by the user into an array of bytes.
                byte[] send_buffer = Encoding.ASCII.GetBytes(text_to_send);

                // Remind the user of where this is going.
                AddLog(String.Format("SND-sending to address: {0} port: {1}", sending_end_point.Address, sending_end_point.Port));

                try
                {
                    sending_socket.SendTo(send_buffer, sending_end_point);

                    AddLog("SND-Message OK");
                }
                catch (Exception send_exception)
                {
                    AddLog("SND-Erro! " + send_exception.Message);
                }
            }
        }

        private void backgroundWorker1_DoWork(object sender, DoWorkEventArgs e)
        {
            bool done = false;
            UdpClient listener = new UdpClient(listenPort, AddressFamily.InterNetwork);
            IPEndPoint groupEP = new IPEndPoint(IPAddress.Parse("10.0.0.100"), listenPort);
            string received_data;
            byte[] receive_byte_array;

            backgroundWorker1.ReportProgress(0, "REC-Waiting for broadcast");
            try
            {
                while (!done)
                {
                    receive_byte_array = listener.Receive(ref groupEP);
                    received_data = Encoding.ASCII.GetString(receive_byte_array, 0, receive_byte_array.Length);

                    var message = String.Format("REC- Broadcast from {0} : {1}\n", groupEP.ToString(), received_data);
                    backgroundWorker1.ReportProgress(0, message);
                }
            }
            catch (Exception ex)
            {
                backgroundWorker1.ReportProgress(0, "REC-" + ex.ToString());
            }

        }

        private void backgroundWorker1_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            var message = e.UserState as string;
            AddLog(message);
        }

        private void AddLog(String text)
        {
            if (!string.IsNullOrEmpty(text))
                textBox1.Text = String.Format("{0}-{1}\r\n{2}", DateTime.Now.ToString("HH:mm:ss"), text, textBox1.Text);
        }

        public void OpenTheDoor()
        {
            string message = "OPENDOOR";
            IPAddress ip = IPAddress.Parse("10.0.0.8");
            int port = listenPort; //11000;

            IPEndPoint endpoint = new IPEndPoint(ip, port);

            SendMessage(message, endpoint);
        }

        public void SendMessage(string message, IPEndPoint endpoint)
        {
            TcpClient client = new TcpClient();

            // the socket object must have an array of bytes to send.
            // this loads the string entered by the user into an array of bytes.
            byte[] sendBuffer = Encoding.ASCII.GetBytes(message);

            // Remind the user of where this is going.
            AddLog(String.Format("SND-sending to address: {0} port: {1}", endpoint.Address, endpoint.Port));

            try
            {
                client.Connect(endpoint);
                client.Client.Send(sendBuffer);

                client.Close();
                AddLog("SND-Message OK");
            }
            catch (Exception send_exception)
            {
                AddLog("SND-Erro! " + send_exception.Message);
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            OpenTheDoor();
        }
    }
}
