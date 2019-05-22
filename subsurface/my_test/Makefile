PROG =	make_subsurface

SRCS =	make_subsurface.f writepfb.f pfb_read.f

OBJS =	make_subsurface.o writepfb.o pfb_read.o

FC = gfortran
FFLAGS = -Wall -fimplicit-none -pedantic -fcheck=all -g -fdump-core -fbacktrace -ffpe-trap=invalid,overflow,underflow,zero

all: $(PROG)

$(PROG): $(OBJS)
	$(FC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	rm -f $(OBJS)
distclean:
	rm -f $(PROG) $(OBJS)
