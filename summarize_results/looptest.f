      INTEGER :: i, j, k

      iloop: do i = 1, 9
        write(*,*) 'i = ', i
        jloop: do j = 1, 9
          write(*,*) '   j = ', j
          if (i.ne.2) then
            kloop: do k = 1, 3
              write(*,*) '     k = ', k
              if (k.ne.3) then
                write(*,*) '     k.ne.3', k, 'next i'
                exit jloop
              endif
            end do kloop
          endif
          write(*,*)  i*j
        end do jloop
      end do iloop
      end
