-module(portRedirect).
-export([forward/2, handle/2, handle/3]).

forward(SourcePort, DestPort)-> {ok, LSock} = gen_tcp:listen(SourcePort, [binary, {active, false}]), acceptLoop(LSock, DestPort).

acceptLoop(LSock, DestPort)-> {ok, SourceSock} = gen_tcp:accept(LSock), {ok, DestSock} = gen_tcp:connect({127,0,0,1}, DestPort, [binary, {active, false}]), bothWays(SourceSock, DestSock), acceptLoop(LSock, DestPort).

bothWays(SourceSock, DestSock)-> Pid = spawn(?MODULE, handle, [SourceSock, DestSock]), spawn(?MODULE, handle, [DestSock, SourceSock, Pid]).

handle(SourceSock, DestSock)-> case gen_tcp:recv(SourceSock, 0) of
		{error, closed}-> gen_tcp:close(DestSock), exit(closed);
		{ok, Data}-> gen_tcp:send(DestSock, Data)
	end, handle(SourceSock, DestSock).

handle(SourceSock, DestSock, Pid)-> link(Pid), handle(SourceSock,DestSock).
