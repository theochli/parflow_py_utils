      subroutine test(nx,ny,nz,dx,dy,dz,arroutfnam,arrin,arrout)
      integer, intent(in) :: nx, ny, nz
      double precision dx,dy,dz
      double precision, dimension(nx,ny), intent(in) :: arrin
      double precision, dimension(nx,ny,nz), intent(out) :: arrout
      character*(*), arroutfnam


Cf2py intent(in) arrin, arroutfnam, nx,ny,nz,dx,dy,dz
Cf2py intent(out) arrout


C      print*,nx,ny,arrin

C      dx=10.0d0
C      dy=10.0d0
C      dz=1.0d0


C Test operation to the array
      do i = 1, nx
           do j = 1, ny
                do k = 1, nz
                     if(k.eq.1) then
                         arrout(i,j,k) = 0
                     else
                         arrout(i,j,k) = arrin(i,j) + 2
                     end if
                end do
           end do
      end do

C     Write to pfb output
      call pf_write(arrout,arroutfnam,nx,ny,nz,dx,dy,dz)
      end subroutine test
