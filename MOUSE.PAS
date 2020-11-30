unit mouse;

interface

uses dos;

function initmouse:word;
(*initializes mouse returns no. buttons: and if mouse is intalied:*)

procedure ShowMouseCursor;
(*turns mouse cursor on*)

procedure HideMouseCursor;
(*turns mouse cursor off*)

procedure GetMousePostion(var status:byte;var x:word;var y:word);
(*tell mouse postion and wether or not button is pressed*)

procedure SetMousePostion(x:word;y:word);
(*Sets mouse to certain postion*)

procedure SetTextCursorType(attribute:word;screen:word;cursor:word);
(*attribute is 0 for attribute,1 for hardware
if attribute is 0,cursor attributes are anded with screen and xored with cursor
if attrib is 1, screen and cursor select the start and stop scan lines*)

function TextCursorStat:word;

procedure TextCursorOff;

procedure SetTextCursorHeight(height:boolean);

procedure TextCursorOn(Stat:word);

procedure SetMouseXLimits(Xmin:word;Xmax:word);

procedure SetMouseYLimits(Ymin:word;Ymax:word);

function ButtonPressInfo(button:word;var status:byte;(*var press:byte;*)var x:word;var y:word):word;

implementation

var
regs:registers;

	function initmouse:word;
	var
	temp:word;

	begin
		regs.ax:=0;
		intr($33,regs);
		temp:=regs.bx;
		temp:=temp or (regs.ax and $ff00);
		initmouse:=temp;
	end;

	procedure ShowMouseCursor;
	begin
		regs.ax:=1;
		intr($33,regs);
	end;

	procedure HideMouseCursor;
	begin
		regs.ax:=2;
		intr($33,regs);
	end;

	procedure GetMousePostion(var status:byte;var x:word;var y:word);
	begin
		regs.ax:=3;
		intr($33,regs);
		status:=regs.bx;
		x:=regs.cx;
		y:=regs.dx;
	end;

	procedure SetMousePostion(x:word;y:word);
	begin
		regs.ax:=4;
		regs.cx:=x;
		regs.dx:=y;
		intr($33,regs);
	end;

	procedure SetMouseXLimits(Xmin:word;Xmax:word);
	begin
		regs.ax:=7;
		regs.cx:=xmin;
		regs.dx:=xmax;
		intr($33,regs);
	end;

	procedure SetMouseYLimits(Ymin:word;Ymax:word);
	begin
		regs.ax:=8;
		regs.cx:=ymin;
		regs.dx:=ymax;
		intr($33,regs);
	end;

	function ButtonPressInfo(button:word;var status:byte;(*var press:byte;*)var x:word;var y:word):word;
	var
	temp:word;

	begin
		regs.ax:=5;
		regs.bx:=button;
		intr($33,regs);
		status:=regs.ax;
		ButtonPressInfo:=regs.bx;
		x:=regs.cx;
		y:=regs.dx;
	end;

	procedure SetTextCursorType(attribute:word;screen:word;cursor:word);
	begin
		regs.ax:=$a;
		regs.bx:=word(attribute);
		regs.cx:=word(screen);
		regs.dx:=word(cursor);
		intr($33,regs);
	end;

	function TextCursorStat:word;
	var
	stat:word;

	begin
		regs.ax:=$300;
		regs.bx:=$0;
		intr($10,regs);
		textcursorstat:=regs.cx;
	end;

	procedure TextCursorOff;
	begin
		regs.ax:=$100;
		regs.cx:=$2000;
		intr($10,regs);
	end;

	procedure SetTextCursorHeight(height:boolean);
	begin
		regs.ax:=$100;
		if height=true then regs.cx:=$d
		else regs.cx:=$c0d;
		intr($10,regs);
	end;

	procedure TextCursorOn(Stat:word);
	begin
		regs.ax:=$100;
		regs.cx:=stat;
		intr($10,regs);
	end;

end.