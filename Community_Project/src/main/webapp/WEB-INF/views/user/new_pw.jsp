<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<c:set var="rootPath" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
	<%@ include file="/WEB-INF/views/include/include_head.jspf" %>
	<style>
		#find_form {
			width: 420px;
			height: 445px;
			margin: 0 auto;
			text-align: center;
		}
		#find_form input, #find_form button {
			width: 70%;
		}
		.label {
			padding: 0.5rem 0px;
		}
		#btn_confirm {
			margin-top: 30px;
		}
	</style>
	<script>
		$(function() {
			let enable_btn_confirm = true
			$("#password").focus()
			
			$(document).on("click", "#btn_confirm", function() {
				let password = $("#password")
				let re_password = $("#re_password")
				
				if (password.val() == "") {
					alert("비밀번호를 입력하세요.")
					password.focus()
					return false
				} else if (re_password.val() == "") {
					alert("비밀번호 확인을 입력하세요.")
					re_password.focus()
					return false
				} else if (password.val() != re_password.val()) {
					alert("비밀번호가 다릅니다.\n다시 확인하세요.")
					re_password.focus()
					return false
				}
				
				
				$.ajax({
					url : "${rootPath}/user/new-pw",
					type : "POST",
					data : {
						"${_csrf.parameterName}" : "${_csrf.token}",
						enc_username : $("#enc_username").val(),
						password : $("#password").val(),
						re_password : $("#re_password").val()
					},
					beforeSend: function(ajx) {
						// 유효성 검사 통과 시
						// 서버 부하를 줄이기 위해 ajax 완료될 때까지 버튼 기능 끄기
						enable_btn_confirm = false
					},
					success : function(result) {
						// 비밀번호 유효성 검사 성공(0 이상)
						if(result > 0) {
							alert("비밀번호가 변경되었습니다.")
							document.location.replace("${rootPath}/")
						} else if(result == 0) {
							// 비밀번호 유효성 검사 실패(0)
							alert("비밀번호를 정확히 입력하세요.")
							re_password.focus()
							return false
						} else if(result == -1) {
							// enc_username 복호화 실패
							alert("잘못된 요청입니다.")
							return false
						}
					},
					error : function(result) {
						alert("서버 통신 오류")
					}
				}).always(function() {
					enable_btn_confirm = true
				})
			})
		})
	</script>
</head>
<body>
	<%@ include file="/WEB-INF/views/include/include_nav.jspf" %>
	<header>
		<h2><a class="header_item">비밀번호 재설정</a></h2>
	</header>
	<form:form id="find_form" modelAttribute="userVO" autocomplete="${FORM_AUTOCOMPLETE}">
		<p>새로운 비밀번호를 입력하세요</p><br/>
		<input id="enc_username" name="enc_username" value="${ENC_USER}" type="hidden"/>
		<div class="label">
			<label for="password">새 비밀번호</label>
		</div>
		
		<div>
			<input id="password" name="password" type="password"/>
		</div>
		
		<div class="label">
			<label for="re_password">새 비밀번호 확인</label>
		</div>
		
		<div>
			<input id="re_password" name="re_password" type="password"/>
		</div>
		
		<button id="btn_confirm" class="btn_confirm" type="button">확인</button>
	</form:form>
</body>
</html>