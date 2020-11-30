program songs;
uses crt;

type
	notetype = record
		octave: integer; {0=middle C}
		pitch: char; {ABCDEFG (R for REST),(T for TEMPO) lower case for sharp}
		duration: char; {whqes for whole,half,etc. upper case for dotted}
	end;
	storepointer = ^storetype;
	storetype = record
		note:notetype;
		pointer:storepointer;
	end;
var
	tempo: real; {1.0 = normal}
	fp: text;
	filename: string;
	note: notetype;
	newpoint,lastpoint,startpoint:storepointer;
	storedat: storetype;
	heaptop: ^integer;
	errorflag:boolean;
	code:integer;
	speed:integer;

function fileexists(filename:string): boolean;
var f: file;
begin
	{$I-}
	assign(f,filename);
	reset(f);
	close(f);
	{$I+}
	fileexists:=(ioresult =0) and (filename <> '');
end;

procedure playnote(note: notetype);
var
	i,length,tone: integer;
begin
	case note.pitch of
		'A': tone:=440;{reg}
		'a': tone:=466;{sharp}
		'B': tone:=494;
		'C': tone:=523;
		'c': tone:=554;
		'D': tone:=587;
		'd': tone:=622;
		'E': tone:=659;
		'F': tone:=699;
		'f': tone:=740;
		'G': tone:=784;
		'g': tone:=831;
		'T','t': begin
			speed:=note.octave;
			exit;
		end;
		'R','r': tone:=0;
		else begin
			halt(3);
		end;
	end;
	case note.duration of
		'w': length:=speed;
		'W': length:=speed*3 div 2;
		'h': length:=speed div 2;
		'H': length:=speed*3 div 4;
		'q': length:=speed div 4;
		'Q': length:=speed*3 div 8;
		'e': length:=speed div 8;
		'E': length:=speed*3 div 16;
		's': length:=speed div 16;
		'S': length:=speed*3 div 32;
		else begin
			halt(3);
		end;
	end;
	length:=round(length/tempo);
	for i:= 1 to note.octave do begin
		tone:=tone*2;
	end;
	for i:= -1 downto note.octave do begin
		tone:=tone div 2;
	end;
	sound(tone);
	delay(length);
	nosound;
end; {playnote}

begin {songs}
	speed:=1000;
	errorflag:=false;
	if (paramcount < 1) or (paramcount > 2) then begin
		writeln('Syntax: songs filename [tempo]');
		writeln('Contents of filename must have format similar to oldmac.mus');
		writeln('Tempo must be between 0.1 and 10.0 (default=1.0)');
		halt(1);
	end;
	filename:=paramstr(1);
	if not fileexists(filename)then halt(2);
	assign(fp,filename);
	reset(fp);
	tempo:=1.0;
	if paramcount = 2 then begin
		val(paramstr(2),tempo,code);
		if code <> 0 then halt(4);
		if (tempo < 0.1) or (tempo > 10.0) then halt(4);
	end;
	mark(heaptop);
	startpoint:=nil;
	while not eof(fp) do begin
		{$I-}
		readln(fp,note.pitch,note.duration,note.octave);
		if ioresult <> 0 then begin
			errorflag:=true;
		end;
		{$I+}
		if upcase(note.pitch) <> 'T' then begin
			if (note.octave<-3) or (note.octave>3) then begin
				errorflag:=true;
			end;
		end
		else begin
			if (note.octave<500) or (note.octave>2000) then begin
				errorflag:=true;
			end;
		end;
		new(newpoint);
		newpoint^.pointer:=nil;
		newpoint^.note:=note;
		if startpoint = nil then
			startpoint:=newpoint
		else begin
			lastpoint^.pointer:=newpoint;
		end;
		if errorflag then lastpoint^.pointer:=nil;
		lastpoint:=newpoint;

	end;
	close(fp);
	newpoint:=startpoint;
	repeat
		playnote(newpoint^.note);
		newpoint:=newpoint^.pointer;
	until newpoint = nil;
	release(heaptop);
	if errorflag then halt(3);
	halt(0);
end.