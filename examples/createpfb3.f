C Simple code to write a 3D pfb file
C from a 2D land cover file and
C land cover-layer depth (2D) lookup matrix
C Meant to be compiled using f2py and
C used in python to facilitate
C iterative scenario and parameter
C permutations.

      subroutine createpfb3(nx,ny,nz,nlc,dx,dy,dz,arroutfnam,arrin,lcin,
     $  arrout)
      integer, intent(in) :: nx, ny, nz, nlc
      double precision, intent(in) :: dx,dy,dz
      integer, dimension(nx,ny), intent(in) :: arrin
      double precision, dimension(nz,nlc), intent(in) :: lcin
      double precision, dimension(nx,ny,nz), intent(out) :: arrout
      character*(*), arroutfnam


Cf2py intent(in) arrin, arroutfnam
Cf2py intent(in) lcin
Cf2py intent(in) nx,ny,nz,nlc,dx,dy,dz
Cf2py intent(out) arrout

C Use lcin matrix to fill in values for 3D array

      do i = 1, nx
           do j = 1, ny
                do k = 1, nz
                     arrout(i,j,k) = lcin(k, arrin(i,j))
                end do
           end do
      end do

C     Write to pfb output
      call pf_write(arrout,arroutfnam,nx,ny,nz,dx,dy,dz)
      end subroutine createpfb3
