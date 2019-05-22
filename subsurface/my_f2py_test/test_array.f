      subroutine test(nx,ny,arrin,nz,arrout)
      integer, intent(in) :: nx, ny
      integer, dimension(nx,ny), intent(in) :: arrin
      integer, intent(in) :: nz
      integer, dimension(nx,ny,nz), intent(out) :: arrout
Cf2py intent(in) arrin
Cf2py intent(out) arrout
C      print*,nx,ny,arrin

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

      end subroutine test
