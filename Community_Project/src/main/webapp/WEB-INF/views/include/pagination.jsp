<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="rootPath" value="${pageContext.request.contextPath}" />
<style>
	article.page_box {
		margin:15px auto;
		padding:16px;
		border-top: 1px solid gree;
		border-buttom: 1px solid gree;
	}
	ul.page_body {
		list-style:none;
		display: flex;
		justify-content: center;
		align-items: center;
	}
	.page_link {
		position: relative;
		display: block;
		padding: 0.5rem 0.75rem;
		line-height: 1.25;
		color:#007bff !important;
		background-color: #fff;
		border:1px solid #DEE2E6;
		text-decoration: none;
		cursor: pointer;
	}
	.page_link:hover {
		color:#0056B3 !important;
		background-color: #E9ECEF;
		border-color: #DEE2E6;
		text-decoration: none;
	}
	.page_link:focus {
		z-index:3;
		outline: 0;
		box-shadow: 0 0 0 0.2rem rgba(0,123,255,0.25);
	}
	li.page_item.active .page_link{
		z-index:3;
		color:#fff !important;
		background-color: #007BFF;
		border-color:  #007BFF;
	}
</style>
<script>
	$(function() {
		$(document).on("click", ".page_middot", function() {
			let jump_page = prompt("이동할 페이지 (1~" + ${PAGE_DTO.pageCount} + ")")
			
			if(jump_page != null) {
				document.location.href = "?pageNo=" + jump_page + "${PAGE_DEFAULT_QUERY}"
			}
		})
	})
</script>
<article class="page_box">
	<ul class="page_body">
		<li class="page_item"><a class="page_link" href="?pageNo=1${PAGE_DEFAULT_QUERY}">처음</a></li>
		<li class="page_item"><a class="page_link" href="?pageNo=${PAGE_DTO.prevPageNo}${PAGE_DEFAULT_QUERY}">&lt;</a></li>
		<c:if test="${PAGE_DTO.startPageNo > 1}">
			<li class="page_item"><a class="page_link page_middot">&middot;&middot;&middot;</a></li>
		</c:if>
		
		<c:forEach begin="${PAGE_DTO.startPageNo}" end="${PAGE_DTO.endPageNo}" var="pageNo">
			<li class="page_item <c:if test='${pageNo == PAGE_DTO.pageNo}'>active</c:if>"><a class="page_link" href="?pageNo=${pageNo}${PAGE_DEFAULT_QUERY}">${pageNo}</a></li>
		</c:forEach>
		
		<c:if test="${PAGE_DTO.endPageNo < PAGE_DTO.pageCount}">
			<li class="page_item"><a class="page_link page_middot">&middot;&middot;&middot;</a></li>
		</c:if>
		<li class="page_item"><a class="page_link" href="?pageNo=${PAGE_DTO.nextPageNo}${PAGE_DEFAULT_QUERY}">&gt;</a></li>
		<li class="page_item"><a class="page_link" href="?pageNo=${PAGE_DTO.pageCount}${PAGE_DEFAULT_QUERY}">끝</a></li>
	</ul>
</article>