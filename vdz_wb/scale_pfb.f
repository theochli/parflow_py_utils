C Code to apply scaling factors to 3D
C pfb outputs of a parflow simulation.
C Meant to be compiled using f2py and
C used in python, to visualize outputs
C of simulation

      subroutine scale_pfb(pfbinfnam,vdzarr,pfboutfnam,
     & nx,ny,nz,dx,dy,dz)
      integer, intent(in) :: nx, ny, nz
      double precision, intent(in) :: dx,dy,dz
      double precision, dimension(nz,1), intent(in) :: vdzarr
      character*(*), pfbinfnam
      character*(*), pfboutfnam
      integer :: i,j
      double precision, dimension(nx,ny,nz) :: arrin
      double precision, dimension(nx,ny,nz), intent(out):: arrout

Cf2py intent(in) pfbinfnam, vdzarr, pfboutfnam
Cf2py intent(in) nx,ny
Cf2py intent(in) dx,dy,dz
Cf2py intent(out) arrout

C Read in the pfb file
      call pfb_read(arrin,pfbinfnam, nx, ny, nz)

      print*, arrin(1,1,10)
      print*, vdzarr(10,1)
      print*, arrin(1,1,10)*vdzarr(10,1)
C      print*, arrin

C 10 is the top of domain, 1 is the bottom of domain
      do i = 1, nx
                 do j = 1, ny
                   arrout(i,j,10)= (arrin(i,j,10))*vdzarr(10,1)
                   arrout(i,j,9)= (arrin(i,j,9))*vdzarr(9,1)
                   arrout(i,j,8)= (arrin(i,j,8))*vdzarr(8,1)
                   arrout(i,j,7)= (arrin(i,j,7))*vdzarr(7,1)
                   arrout(i,j,6)= (arrin(i,j,6))*vdzarr(6,1)
                   arrout(i,j,5)= (arrin(i,j,5))*vdzarr(5,1)
                   arrout(i,j,4)= (arrin(i,j,4))*vdzarr(4,1)
                   arrout(i,j,3)= (arrin(i,j,3))*vdzarr(3,1)
                   arrout(i,j,2)= (arrin(i,j,2))*vdzarr(2,1)
                   arrout(i,j,1)= (arrin(i,j,1))*vdzarr(1,1)
                 end do
            end do

C      print*, arrout

C write to pfb output

      call pf_write(arrout,pfboutfnam,nx,ny,1,dx,dy,dz)

      end subroutine scale_pfb
