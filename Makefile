.PHONY: demo1 demo2

demo1: mycat libdecompresser.so mytar
	rm -rf demo
	mkdir demo
	seq 1 100000 > demo/a
	seq 1 1000000 > demo/b
	seq 1 10000000 > demo/c
	du -sh demo
	rm -f out.mytar
	echo demo/a demo/b demo/c | ./mytar -z out.mytar
	du -sh out.mytar
	rm -rf demo
	@echo "############################## Rodando mycat com um arquivo que nao existe ##########################################################"
	./mycat demo/a
	@echo ""
	@echo "############################## Rodando mycat com um arquivo montado virtualmente atraves do LD_PRELOAD ################"
	VIRTUAL_TAR_FS=out.mytar LD_PRELOAD=./libdecompresser.so ./mycat demo/a | head -n 3

demo2: mycat libdecompresser.so mytar
	rm -rf demo
	mkdir demo
	seq 1 100000 > demo/a
	seq 1 1000000 > demo/b
	seq 1 10000000 > demo/c
	du -sh demo
	gzip demo/a
	gzip demo/b
	gzip demo/c
	rm -f out.mytar
	echo demo/a.gz demo/b.gz demo/c.gz | ./mytar out.mytar
	rm -rf demo
	du -sh out.mytar
	@echo "############################## Rodando mycat com um arquivo que nao existe ##########################################################"
	./mycat demo/a.gz
	@echo ""
	@echo "############################## Rodando mycat com um arquivo montado virtualmente atraves do LD_PRELOAD ################"
	VIRTUAL_TAR_FS=out.mytar LD_PRELOAD=./libdecompresser.so ./mycat demo/a.gz | head -n 3

mycat: mycat.cpp
	g++ -o mycat mycat.cpp

libdecompresser.so: decompresser.cpp src/libbrg.a
	g++ -std=c++11 -fPIC -shared -o libdecompresser.so $^ -ldl -lpthread -lz

mytar: mytar.cpp src/libbrg.a
	g++ -std=c++11 -o $@ $^ -lz

src/libbrg.a: src/MMFile.o src/zip.o src/crypt.o src/fd.o
	rm -f $@
	ar rcs $@ $^

%.o: %.cpp
	g++ -fPIC -std=c++11 -c -o $@ $^ 

clean:
	-rm libdecompresser.so mycat mytar
	-rm src/*.o
	-rm src/*.a
	-rm out.mytar