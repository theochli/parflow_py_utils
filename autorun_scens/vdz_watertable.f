C Code to calculate depth of water table
C from saturation  pfb outputs of a
C parflow simulation.
C Meant to be compiled using f2py and
C used in python, to visualize outputs
C of simulation

      subroutine vdz_watertable(pfbinfnam,vdzarr,pfboutfnam,
     & nx,ny,nz,dx,dy,dz,arrout)
      integer, intent(in) :: nx, ny, nz
      double precision, intent(in) :: dx,dy,dz
      double precision, dimension(nz,1), intent(in) :: vdzarr
      character*(*), pfbinfnam
      character*(*), pfboutfnam
      integer :: i,j,k,kk
      double precision, dimension(nx,ny,nz) :: arrin
      integer, dimension(nx,ny) :: arrmed
      double precision,dimension(nx,ny),intent(out) :: arrout


Cf2py intent(out) arrout

C Read in the pfb file
      call pfb_read(arrin,pfbinfnam, nx, ny, nz)

C      print*, arrin(1,1,10)
C      print*, vdzarr(10,1)
C      print*, arrin(1,1,10)*vdzarr(10,1)
C      print*, arrin

C      print*, arrin
C For each horizontal position (i,j), find the top-most
C  layer that has saturation == 1, save that in an
C  intermediate array

      iloop: do i = 1, nx
            print *, 'i = ', i
            jloop: do j = 1, ny
                  print *, 'j = ', j
C From the top of the domain, check if saturated
C   record highest layer number that is saturated in arrmed
                  kloop: do k = nz, 1, -1
                     print *, 'k = ', k
                     print *, 'arrin(i,j,k) = ', arrin(i,j,k)
                     if (arrin(i,j,k).eq.1) then
C                      check if all layers under it are 1
                        kk = k-1
                        
                        if (kk.eq.0) then
                          arrmed(i,j)=k
                          print*, 'arrmed(i,j,k) set to ', k
                          print*, '***********************'
C                         this means k = 1, bottom of domain
C                         nothing to check underneath
                          exit kloop
                        end if 
                        
                        kkloop: do while (kk.gt.1)
                          print *, 'kk=', kk 
                          print *, 'arrin(i,j,kk) = ', arrin(i,j,kk)
                        
                          
                          if (arrin(i,j,kk).ne.1) then
C                           go to next k down (continue kloop) 
                            exit kkloop
                          else 
                            kk=kk-1 ! goto next layer down
                          endif
                        end do kkloop 
                        
                        
                        if ((kk.eq.1).and.(arrin(i,j,1).eq.1)) then 
C                       did not exit before getting to bottom
C                       ie, from k to bottom, layers under
C                       are saturated
                          arrmed(i,j)=k
                          print*, 'arrmed(i,j,k) set to ', k
                          print*, '************************'
                          exit kloop
                        end if
                        
                        
                    end if       
                  end do kloop

            end do jloop
      enddo iloop


C Apply vdz layer depths to arrmed to
C get depth to watertable

      do i = 1, nx
            do j = 1, ny
                  arrout(i,j)=vdzarr((arrmed(i,j)),1)
            end do
       end do


C     Write to pfb output
      call pf_write(arrout,pfboutfnam,nx,ny,1,dx,dy,dz)
      end subroutine vdz_watertable
