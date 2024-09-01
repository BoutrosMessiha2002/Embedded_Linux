#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <iostream>
constexpr unsigned int SERVER_PORT = 50544;
constexpr unsigned int MAX_BUFFER = 128;

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        std::cerr << "Usage: " << argv[0] << " <server_address>" << std::endl;
        return 1;
    }

    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0)
    {
        std::cerr << "socket error" << std::endl;
        return 2;
    }

    struct hostent *server = gethostbyname(argv[1]);
    if (server == nullptr)
    {
        std::cerr << "server error" << std::endl;
        close(sockfd);
        return 3;
    }

    struct sockaddr_in serv_addr;
    bzero((char *)&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr, server->h_length);
    serv_addr.sin_port = htons(SERVER_PORT);

    if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
        std::cerr << "connect error" << std::endl;
        close(sockfd);
        return 4;
    }

    char buffer[MAX_BUFFER];
    std::string userInput;

    
        bzero(buffer, MAX_BUFFER);
        
        // Receive initial connection message
        int n = read(sockfd, buffer, MAX_BUFFER-1);
        if (n <= 0)
        {
            std::cerr << "read from socket failed or server disconnected" << std::endl;
        }
        while (true)
    {
        std::cout << "What's your message: ";
        getline(std::cin, userInput);

        // Send message to server
        write(sockfd, userInput.c_str(), userInput.length());

        if (userInput == "end communication")
        {
            std::cout << "Ending communication" << std::endl;
            break;
        }

        // Read server reply
        char new_buff[MAX_BUFFER];
        bzero(new_buff, MAX_BUFFER);
        n = read(sockfd, new_buff, MAX_BUFFER-1);
        if (n <= 0)
        {
            std::cerr << "read from socket failed or server disconnected" << std::endl;
            break;
        }
        std::cout << "server message: " << new_buff << std::endl;
    }

    close(sockfd);
    return 0;
}
