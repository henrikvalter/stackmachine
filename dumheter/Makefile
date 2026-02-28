

Main: Abs.hs Vhdl_interface.hs Assembler.hs Interpreter.hs
	ghc Main.hs -o a.out
	./a.out

Vhdl_interface: Vhdl_interface.hs Abs.hs Assembler.hs
	ghc Vhdl_interface.hs -o a.out
	./a.out

Assembler: Assembler.hs Abs.hs
	ghc Assembler.hs -o a.out
	./a.out

Interpreter: Interpreter.hs Abs.hs
	ghc Interpreter.hs -o a.out
	./a.out

clean:
	rm *.o *.hi *.out *.asm
