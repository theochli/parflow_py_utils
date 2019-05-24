C    This program is free software: you can redistribute it and/or modify
C    it under the terms of the GNU General Public License as published by
C    the Free Software Foundation, either version 3 of the License, or
C    (at your option) any later version.
C
C    This program is distributed in the hope that it will be useful,
C    but WITHOUT ANY WARRANTY; without even the implied warranty of
C    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C    GNU General Public License for more details.
C
C    You should have received a copy of the GNU General Public License
C    along with this program.  If not, see <http://www.gnu.org/licenses/>.
C
C    subroutine pf_write distilled from ParFlow pftools prepostproc r605
      subroutine pf_write(x,filename,ixlim,iylim,izlim,dx,dy,dz)
      implicit none
      integer i,j,k, ixlim, iylim, izlim,
     .          ns, ix, iy, iz, rx, ry, rz
      real*8 x(ixlim,iylim,izlim),dx, dy, dz, x1, y1, z1
      character(len=*) filename
C
C     Open File
C
      print*, filename
      open(15,file=filename,form='unformatted',
     .     access='stream',convert='BIG_ENDIAN', status='unknown')
C
C Calc domain bounds
C
      ix = 0
      iy = 0
      iz = 0

      ns = 1

      rx = 1
      ry = 1
      rz = 1

      x1 = dble(ixlim)*dx
      y1 = dble(iylim)*dy
      z1 = dble(izlim)*dz
!
!       Write header info
!

      write(15) x1
      write(15) y1
      write(15) z1

      write(15) ixlim
      write(15) iylim
      write(15) izlim

      write(15) dx
      write(15) dy
      write(15) dz

      write(15) ns

      write(15) ix
      write(15) iy
      write(15) iz

      write(15) ixlim
      write(15) iylim
      write(15) izlim

      write(15) rx
      write(15) ry
      write(15) rz


      do  k=1,izlim
           do  j=1,iylim
                do  i=1,ixlim
                     write(15) x(i,j,k)
                end do
           end do
      end do

      close(15)
      return
      end
