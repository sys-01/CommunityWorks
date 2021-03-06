package com.sif.community.service.user;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sif.community.dao.AuthoritiesDao;
import com.sif.community.model.AuthorityVO;
import com.sif.community.model.BoardInfoVO;
import com.sif.community.model.CategoryVO;
import com.sif.community.model.PaginationDTO;
import com.sif.community.model.UserDetailsVO;
import com.sif.community.service.board.BoardInfoService;
import com.sif.community.service.board.CategoryService;
import com.sif.community.service.board.itf.PaginationService;
import com.sif.enums.PageDefaultLimit;
import com.sif.enums.PageLocation;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor
@Service
public class AdminService {
	
	private final UserService userSvc;
	private final PaginationService pageSvc;
	private final AuthoritiesDao authDao;
	private final BoardInfoService boardInfoSvc;
	private final CategoryService cateSvc;
	
	// 관리자가 다른 유저 정보 수정하기
	// 유저 정보 form과 권한 정보 form 값을 가져와서
	// 유저 정보는 유저 테이블에, 권한은 권한 테이블에 저장하기
	@Transactional
	public int updateUserFromAdmin(UserDetailsVO userVO, String[] arrAuth) {
		int ret = this.validUpdateUserFromAdmin(userVO);
		// 유효성 검사 통과 실패 시 유효성 검사 결과값 바로 리턴
		if(ret < 0) return ret;
		
		// DB의 유저 정보 불러오기
		UserDetailsVO dbUserVO = userSvc.findByUsername(userVO.getUsername());
		
		// 기존의 유저정보에 form에서 입력받은 정보 새로 세팅하기
		// 계정활성여부, 닉네임, 이메일, 핸드폰, 생년, 생월, 생일
		dbUserVO.setEnabled(userVO.isEnabled());
		dbUserVO.setNickname(userVO.getNickname());
		dbUserVO.setEmail(userVO.getEmail());
		dbUserVO.setPhone(userVO.getPhone());
		
		dbUserVO.setYear(userVO.getYear());
		dbUserVO.setMonth(userVO.getMonth());
		dbUserVO.setDay(userVO.getDay());
		
		ret = userSvc.updateUserFromAdmin(dbUserVO);
		
		// 업데이트 성공 시 권한 테이블 업데이트
		if(ret > 0) {
			List<AuthorityVO> authList = new ArrayList<AuthorityVO>();
			for(String auth : arrAuth) {
				//input에서 받은 auth 값이 비어있으면(="") 무시함 
				if(!auth.isEmpty()) {
					AuthorityVO authVO = AuthorityVO.builder()
										.username(dbUserVO.getUsername())
										.authority(auth)
										.build();
					
					authList.add(authVO);
				}
			}
			authDao.delete(dbUserVO.getUsername());
			authDao.insert(authList);
		}
		return ret;
	}
	
	protected int validUpdateUserFromAdmin(UserDetailsVO userVO) {
		String email = userVO.getEmail();
		String birth = String.format("%s-%s-%s", userVO.getYear(), userVO.getMonth(), userVO.getDay());
		int result = 0;
		
		if (email.isEmpty() || !email.matches("^([a-zA-Z0-9_.+-])+\\@(([a-zA-Z0-9-])+\\.)+([a-zA-Z0-9]{1,6})+$")) {
			// 이메일 유효성 검사
			result = -102;
		} else if( !this.dateCheck(birth) ) {
			// 생년월일 유효성 검사
			result = -103;
		} else if(userSvc.findByUsername(userVO.getUsername()) == null) {
			// DB에 존재하는 아이디인지 검사
			result = -200;
		}
		
		return result;
	}
	
	protected boolean dateCheck(String date) {
		SimpleDateFormat dateFormat = new  SimpleDateFormat("yyyy-MM-dd");
		dateFormat.setLenient(false);
		try {
			dateFormat.parse(date);
			return true;
		} catch (Exception e) {
			return false;
		}
	}
	
	public int insertBoard(BoardInfoVO boardInfoVO) {
		return boardInfoSvc.insert(boardInfoVO);
	}
	
	/**
	 * 페이지네이션 DB 저장 메소드
	 * @param dbPageDTO DB에 저장된 데이터가 없으면(null) INSERT, 있으면 UPDATE
	 * @param bi_id 게시판 ID
	 * @param page_location 데이터를 보여줄 페이지 위치(메인페이지, 게시판, 댓글)
	 * <br/>
	 * 들어갈 수 있는 값 목록 enum : {@link com.sif.enums.PageLocation}
	 * @param data_cnt 보여줄 데이터 수
	 * @param page_range 페이지 범위
	 * @return
	 */
	protected int savePagination(PaginationDTO dbPageDTO, Long bi_id, String page_location, int data_cnt, int page_range) {
		int result = 0;
		if(dbPageDTO == null) {
			// dbPageDTO가 없으면 DTO 세팅 후 INSERT
			dbPageDTO = PaginationDTO.builder()
						.page_bi_id(bi_id)
						.page_location(page_location)
						.page_data_cnt(data_cnt)
						.page_range(page_range)
						.build();
			
			result = pageSvc.insert(dbPageDTO);
		} else {
			// dbPageDTO가 있으면 data_cnt, page_range 세팅 후 UPDATE
			dbPageDTO.setDataCount(data_cnt);
			dbPageDTO.setPage_range(page_range);
			
			result = pageSvc.update(dbPageDTO);
		}
		
		return result;
	}
	
	// 관리자 페이지 - 메인 페이지 설정 GET에서 사용할 메소드
	public PaginationDTO mainPageInfo() {
		PaginationDTO pageDTO = pageSvc.findByBiId(null, PageLocation.MAIN.getPage_location());
		if(pageDTO == null) pageDTO = new PaginationDTO();
		
		// 관리자 페이지 - 메인 페이지 설정에서 사용할 변수 세팅
		if(pageDTO.getPage_data_cnt() == 0) pageDTO.setPage_data_cnt(PageDefaultLimit.MAIN.getLimit_value());
		return pageDTO;
	}
	
	// 관리자 페이지 - 메인 페이지 설정 POST에서 사용할 메소드
	public int updateMainPage(int page_data_cnt) {
		PaginationDTO pageDTO = pageSvc.findByBiId(null, PageLocation.MAIN.getPage_location());
		return this.savePagination(pageDTO, null, PageLocation.MAIN.getPage_location(), page_data_cnt, 10);
	}
	
	// 게시판 정보 업데이트 메소드
	@Transactional
	public int updateBoard(BoardInfoVO boardInfoVO, CategoryVO categoryOptionVO) {
		// boardInfoOptionVO에는 bi_id, bi_name, bi_enabled, data_cnt_board, data_cnt_comment, page_range_board, page_range_comment가 들어있다
		// categoryOptionVO에는 카테고리 목록이 들어있다
		
		long bi_id = boardInfoVO.getBi_id();
		String bi_name = boardInfoVO.getBi_name();
		
		// 1. DB의 게시판 정보(tbl_board_info) 불러오기
		BoardInfoVO dbBoardInfoVO = boardInfoSvc.findByBiId(bi_id);
		
		// 2. 유효성 검사
		if(bi_name.length() > 100) {
			// 2-1. 게시판 이름이 100글자를 초과하는 경우
			return -100;
		} else if(dbBoardInfoVO == null) {
			// 2-2. DB에 게시판 ID가 존재하지 않는 경우
			return -200;
		}
		
		// 유효성 검사 통과 시 
		// 3. 기존의 게시판 정보에 form에서 입력받은 정보(게시판 이름, 활성여부) 새로 세팅하기
		dbBoardInfoVO.setBi_name(bi_name);
		dbBoardInfoVO.setBi_enabled(boardInfoVO.isBi_enabled());
		int result = boardInfoSvc.update(dbBoardInfoVO);
		
		// 4. 게시판 정보 업데이트 성공 시 페이지네이션 테이블 INSERT/UPDATE
		if(result > 0) {
			// 4-1. 게시판 pageDTO INSERT/UPDATE
			PaginationDTO pageDTO = pageSvc.findByBiId(bi_id, PageLocation.BOARD.getPage_location());
			result = this.savePagination(pageDTO, bi_id, PageLocation.BOARD.getPage_location(), boardInfoVO.getData_cnt_board(), boardInfoVO.getPage_range_board());
			
			// 4-2. 댓글 pageDTO INSERT/UPDATE
			pageDTO = pageSvc.findByBiId(bi_id, PageLocation.COMMENT.getPage_location());
			result = this.savePagination(pageDTO, bi_id, PageLocation.COMMENT.getPage_location(), boardInfoVO.getData_cnt_comment(), boardInfoVO.getPage_range_comment());
		}
		
		// 5. 페이지네이션 정보 업데이트 성공 시 카테고리 테이블 INSERT/UPDATE
		if(result > 0) {
			List<Long> cate_id_list = categoryOptionVO.getCate_id_list();
			List<String> cate_text_list = categoryOptionVO.getCate_text_list();
			
			// 5-1. form에서 카테고리 리스트를 전달받았으면 카테고리 테이블 업데이트
			if(cate_id_list == null) return result;
			
			List<CategoryVO> categoryList = new ArrayList<CategoryVO>();
			
			for(int i = 0; i < cate_id_list.size(); i++) {
				long cate_id = cate_id_list.get(i);
				String cate_text = cate_text_list.get(i);
				
				// 5-2. cate_id 여부에 따라서 INSERT/UPDATE 선택
				if(cate_id == 0) {
					// cate_id를 입력받지 않았으면(0 이면) INSERT할 VO 생성 후 카테고리 리스트에 추가
					CategoryVO categoryVO = CategoryVO.builder()
							.cate_bi_id(dbBoardInfoVO.getBi_id())
							.cate_text(cate_text)
							.build();
					categoryList.add(categoryVO);
				} else {
					// cate_id를 입력받았으면 기존 DB 카테고리 UPDATE
					CategoryVO categoryVO = CategoryVO.builder()
							.cate_id(cate_id)
							.cate_bi_id(dbBoardInfoVO.getBi_id())
							.cate_text(cate_text)
							.build();
					cateSvc.update(categoryVO);
				}
				
			}
			
			// 5-3. 카테고리 리스트 INSERT
			if(categoryList.size() > 0) cateSvc.insert(categoryList);
		}
		
		return result;
	}
	
	public int changeOrder(long bi_id, long order) {
		return boardInfoSvc.changeOrder(bi_id, order);
	}

	public int deleteCategory(long cate_id) {
		return cateSvc.delete(cate_id);
	}

	public int deleteBoard(long bi_id) {
		return boardInfoSvc.delete(bi_id);
	}

}
