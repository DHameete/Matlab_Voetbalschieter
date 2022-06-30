clear s_port
s_port = serialport('/dev/tty.usbmodem95871501',115200);

%%


while true
    d_str = read(s_port, 8, "uint8")
    
%     sprintf('%4.0f, %4.0f', d_str(1) + d_str(2)*255, d_str(6) + d_str(7)*255)
    sprintf('%3.0f, %3.0f', (d_str(5) + d_str(6)*256 - ...
        bitshift(d_str(6),-7)*65536))


    flush(s_port);

    pause(0.1);
end