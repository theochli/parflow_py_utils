      subroutine test(nx,ny,arrin,arrout)
      integer, intent(in) :: nx, ny
      double precision dx,dy,dz
      double precision, dimension(nx,ny), intent(in) :: arrin
      double precision, dimension(nx,ny,10), intent(out) :: arrout
Cf2py intent(in) arrin
Cf2py intent(out) arrout
      character(100) arroutfnam

      arroutfnam='testout.pfb'

C      print*,nx,ny,arrin

      dx=10.0d0
      dy=10.0d0
      dz=1.0d0


C Test operation to the array
      do i = 1, nx
           do j = 1, ny
                do k = 1, 10
                     if(k.eq.1) then
                         arrout(i,j,k) = 0
                     else
                         arrout(i,j,k) = arrin(i,j) + 2
                     end if
                end do
           end do
      end do

C     Write to pfb output
      call pf_write(arrout,arroutfnam,nx,ny,10,dx,dy,dz)
      end subroutine test
