program musicprog;
uses crt,mouse;
var
stat:word;
init:word;
status:byte;
x:word;
y:word;
hot:integer;
win:integer;
x2:word;
y2:word;
key:char;
count:word;
data:array[0..$efff] of char;
duration:byte;
noteval:char;
durval:char;
octval:shortint;
tempo:longint;
temp:string;
count2:integer;
xx:byte;
yy:byte;

procedure drawoctave(x:byte;y:byte);

begin
	textcolor(black);
	textbackground(white);
	gotoxy(x,y);
	write(#$c2#$c4#$dc#$c4#$dc#$c4#$c2#$c4#$dc#$c4#$dc#$c4#$dc#$c4#$c2);
	gotoxy(x,y+1);
	write(#$b3#$20#$db#$20#$db#$20#$b3#$20#$db#$20#$db#$20#$db#$20#$b3);
	gotoxy(x,y+2);
	write(#$b3#$20#$b3#$20#$b3#$20#$b3#$20#$b3#$20#$b3#$20#$b3#$20#$b3);
	gotoxy(x,y+3);
	write(#$c1#$c4#$c1#$c4#$c1#$c4#$c1#$c4#$c1#$c4#$c1#$c4#$c1#$c4#$c1);
end;

procedure boxes(x:byte;y:byte);

begin
	textcolor(white);
	textbackground(black);
	gotoxy(x,y);
	write(#$db' REST    '#$db' DOTTED '#$db' TEMPO');
	gotoxy(x,y+2);
	write(#$db' WHOLE   '#$db' HALF   '#$db' QUARTER   '#$db' EIGHTH   '#$db' SIXTEENTH');
end;

function hotspot(x:word;y:word):integer;

var
octave:integer;
note:integer;
box:integer;


begin
	hotspot:=0;
	octave:=-1;
	note:=0;
	if ((y=2) or (y=1)) and ((x>4) and (x<74)) then begin
		case x of
			5..17:octave:=0;
			19..31:octave:=1;
			33..45:octave:=2;
			47..59:octave:=3;
			61..73:octave:=4;
		end;
		if octave>=0 then x:=x-octave*14;
		if y=2 then
		case x of
			5:begin
				note:=1;
				write(#7);
			end;
			7:begin
				note:=3;
				write(#7);
			end;
			9:begin
				note:=5;
				write(#7);
			end;
			11:begin
				note:=6;
				write(#7);
			end;
			13:begin
				note:=8;
				write(#7);
			end;
			15:begin
				note:=10;
				write(#7);
			end;
			17:begin
				note:=12;
				write(#7);
			end;
		end;
		if Y=1 then
			case x of
				6:begin
					note:=2;
					write(#7);
				end;
				8:begin
					note:=4;
					write(#7);
				end;
				12:begin
					note:=7;
					write(#7);
				end;
				14:begin
					note:=9;
					write(#7);
				end;
				16:begin
					note:=11;
					write(#7);
				end;
			end;
	end;
	box:=0;
	if (x=4) and (y=5) then begin
		box:=1;
		write(#7); (*rest*)
	end;
	if (x=14) and (y=5) then begin
		box:=2;
		write(#7); (*dotted*)
	end;
	if (x=4) and (y=7) then begin
		box:=3;
		write(#7);   (*Whole*)
	end;
	if (x=14) and (y=7) then begin
		box:=4;
		write(#7);  (*half*)
	end;
	if (x=23) and (y=7) then begin
		box:=5;
		write(#7);  (*quarter*)
	end;
	if (x=35) and (y=7) then begin
		box:=6;
		write(#7);  (*eighth*)
	end;
	if (x=46) and (y=7) then begin
		box:=7;
		write(#7); (*sixteenth*)
	end;
	if (x=23) and (y=5) then begin
		box:=8;{tempo}
		write(#7);
	end;
	if ((x=4) or (x=5)) and (y=9) then begin
		hotspot:= -1;
		exit;
	end;
	if (octave=-1) and (note=0) and (box=0) then exit;
	if box <> 0 then begin
		hotspot:=box;
		exit;
	end;
	if note <> 0 then hotspot:=(note shl 8)+octave;
end;


procedure isinwindow(x:byte;y:byte);

begin
		if (x>=0) and (y>=10) and (status and $1 <> 0) then begin
			textcursoron(stat);
			gotoxy(x+1,y-9);
			{key:=readkey;
			write(key);}
			{if key=#8 then write(#8);
			if key=#13 then write(#13);}
		end;
end;

function exist(filename:string):boolean;
var
fil:file;
result:boolean;
begin
	assign(fil,filename);
	{$I-}
	reset(fil);
	{$I+}
	result:=(IOResult=0);
	exist:=result;
	if result then close(fil);
end;

procedure save;

var
filevar:text;
filename:string;
name:string;
n:integer;
ex:boolean;
dotpos:byte;

begin
	window(47,17,80,22);
	repeat
		clrscr;
		writeln('Enter name to which you want your file to be saved(no extention)');
		writeln('');
		readln(name);
		dotpos:=pos('.',name);
		if dotpos <> 0 then name:=copy(name,1,dotpos-1);
		filename:=name+'.mus';
		ex:=exist(filename);
		if ex=true then begin
			writeln('');
			write(#7'File Exists!!'#7);
			delay(3000);
		end;
		if ex=false then begin
			assign(filevar,filename);
			{$I-}
			rewrite(filevar);
			{$I+}
			if IOResult <> 0 then begin
				writeln('');
				write(#7'Can''t open file!!'#7);
				delay(3000);
				ex:=true;
			end;
		end;
	until ex=false;
	for n:=0 to count-1 do
		write(filevar,data[n]);
	close(filevar);
end;

begin
	count:=0;
	duration:=0;
	clrscr;
	stat:=textcursorstat;
	textcursoroff;
	init:=initmouse;
	SetMouseYLimits(0,95);
	drawoctave(5,1);
	drawoctave(19,1);
	drawoctave(33,1);
	drawoctave(47,1);
	drawoctave(61,1);
	boxes(5,6);
	settextcursortype(0,$0fe,$5d00);
	gotoxy(5,10);
	write(#$db#$db' SAVE');
	window(1,15,80,25);
	showmousecursor;
	repeat
		hot:=0;
		getmousepostion(status,x,y);
		if status and $1 <> 0 then begin
			x:=x div 8;
			y:=y div 8;
			hot:=hotspot(x,y);
			if hot<>0 then begin
				if hot=-1 then save
				else begin
					if (hot<256) and (hot<>1) and (hot<>8) then begin
						if hot = 2 then duration:=duration or $80
						else duration:=duration and ($80) or (hot);
					end
					else begin
						if hot=8 then begin
							duration:=0;
							xx:=wherex;
							yy:=wherey;
							window(35,6,72,6);
							repeat
								clrscr;
								write('Enter tempo(500-2000)?   ');
								{$I-}
								tempo:=0;
								readln(tempo);
								{$I+}
								if (IOResult <> 0) or (tempo<500) or (tempo>2000) then begin
									write(#7'Please enter number within range.'#7);
									delay(5000);
								end;{if}
							until (tempo>=500) and (tempo<=2000);
							str(tempo,temp);
							clrscr;
							window(1,15,80,25);
							gotoxy(xx,yy);
							noteval:='t';
							durval:='w';
							octval:=tempo;
						end;{if}
						if (duration and $7f)<>0 then begin
							if hot=1 then begin
								noteval:='r';
							end
							else begin
								case hot shr 8 of
									1:noteval:='C';
									2:noteval:='c';
									3:noteval:='D';
									4:noteval:='d';
									5:noteval:='E';
									6:noteval:='F';
									7:noteval:='f';
									8:noteval:='G';
									9:noteval:='g';
									10:noteval:='A';
									11:noteval:='a';
									12:noteval:='B';
								end;{case}
							end;{begin}
							case duration and $7f of
								3:durval:='w';
								4:durval:='h';
								5:durval:='q';
								6:durval:='e';
								7:durval:='s';
							end;{case}
							if duration and $80<>0 then durval:=upcase(durval);
						end;
							if (duration and $7f <>0) or (hot=8) then begin
								{write to data}
								data[count]:=noteval;
								write(data[count]);
								count:=succ(count);
								data[count]:=durval;
								write(data[count]);
								count:=succ(count);
								duration:=0;
								if hot<>8 then begin
									octval:=(hot and $ff)-2;
									str(octval,temp);
								end;
								write(temp);
								for count2:=1 to length(temp) do begin
									data[count]:=temp[count2];
									count:=succ(count);
								end;
							{if octval>=0 then begin
								octval:=octval or $30;
								data[count]:=char(octval);
								write(data[count]);
								count:=succ(count);
							end}{if}
							{else begin
								data[count]:='-';
								write(data[count]);
								count:=succ(count);
								octval:=(-octval) or $30;
								data[count]:=char(octval);
								write(data[count]);
								count:=succ(count);
							end;}{else}
								data[count]:=#13;
								write(data[count]);
								count:=succ(count);
								data[count]:=#10;
								write(data[count]);
								count:=succ(count);
							end;{if}
					end;{begin}

				end;{begin}
			end;{if}
			(*repeat
				getmousepostion(status,x,y);
				x:=x div 8;
				y:=y div 8;
				isinwindow(byte(x),byte(y));
			until (status and $1 <> 0) and ((x>=0) and (y<10));*)
			repeat
				getmousepostion(status,x,y);
			until status and $1 = 0;
		end;
	until hot=-1;
	window(1,1,80,25);
	hidemousecursor;
	clrscr;
	textcursoron(stat);
end.