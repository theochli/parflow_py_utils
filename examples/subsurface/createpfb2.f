C Simple code to write a 2D pfb file
C from a 2D land cover file and
C land cover-1D lookup matrix
C Meant to be compiled using f2py and
C used in python to facilitate
C iterative scenario and parameter
C permutations.

      subroutine createpfb2(nx,ny,nlc,dx,dy,dz,arroutfnam,arrin,
     $ lcin_flat, arrout)
      integer, intent(in) :: nx, ny, nlc
      double precision, intent(in) :: dx,dy,dz
      integer, dimension(nx,ny), intent(in) :: arrin
      double precision, dimension(1,nlc), intent(in) :: lcin_flat
      double precision, dimension(nx,ny,1), intent(out) :: arrout
      integer :: nz
      integer :: i,j,k
      character*(*), arroutfnam


Cf2py intent(in) arrin, arroutfnam
Cf2py intent(in) lcin
Cf2py intent(in) nx,ny,nlc,dx,dy,dz
Cf2py intent(out) arrout

C Mannings should only have 2 dimensions, since
C  it only affects the surface

      nz=1

C Use lcin_flat matrix to fill in values for 3D array

      do i = 1, nx
           do j = 1, ny
                do k = 1, nz
                     arrout(i,j,k) = lcin_flat(k, arrin(i,j))
                end do
           end do
      end do

C     Write to pfb output
      call pf_write(arrout,arroutfnam,nx,ny,nz,dx,dy,dz)
      end subroutine createpfb2
